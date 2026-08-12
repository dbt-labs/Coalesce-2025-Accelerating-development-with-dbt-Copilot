# AGENTS.md

## SQL style and naming conventions

Follow `dbt-styleguide.md` for naming and SQL styling conventions in this project. Every new
model must conform to it. The following points are called out explicitly here, in addition to
living in the styleguide, because they have been
observed to get missed:

- **Counts are prefixed `count_<noun>`** (e.g. `count_orders`), never suffixed (`orders_count`).
  Check every aggregate/count column name against this before finishing a model.
- **The terminal CTE - the one immediately before the final `select` - is always named
  `final`** in every model in this project. Never name it after the model itself (e.g. don't
  name the last CTE in `location_performance.sql` `location_performance`) and never reuse an
  earlier CTE's name.
- **Never join a raw, un-aggregated table directly into the same step that does your final
  grouping.** If you need item-level detail (e.g. `order_items`) to compute a metric at a
  coarser grain (e.g. per location per day), aggregate the item-level data to its own grain in
  a dedicated CTE first, then join that pre-aggregated CTE up to the coarser grain. This
  applies even when joining first doesn't cause a double-counting bug - it's a required
  pattern in this project, not just a performance nice-to-have.
- **Default to `left join` when enriching a fact-grain CTE with a dimension/reference table**
  (e.g. joining to `locations` for `location_name`, or `products` for `product_name`). Only
  use `inner join` when you specifically intend to filter out unmatched rows. Every existing
  mart in this project (`order_items`, `orders`, `customers`) enriches with `left join` -
  an `inner join` here will silently drop fact rows on any foreign-key gap, which won't show
  up as a test failure.

## Building new marts

- Before joining raw sources, check whether an existing mart or staging model already
  contains the logic you need (e.g. food/drink classification, revenue totals, customer
  lifetime metrics). Build on top of existing marts rather than re-deriving that logic from
  raw sources - it keeps business logic defined in one place and avoids accidental
  join fan-out.
- When you do need item-level detail (for example, splitting revenue by category), aggregate
  at the most granular level first, then join the aggregate up to the coarser grain. Don't
  join first and then aggregate - it's easy to double-count when a parent record (like an
  order) can match multiple categories, and even when it doesn't cause a bug, pre-aggregating
  first is a required pattern here (see "SQL style" above).
- **Every model needs an actual single-column primary key - not just a test.** If a mart's
  grain has no single natural key (e.g. one row per location per day), generate a surrogate
  key with `{{ dbt_utils.generate_surrogate_key([...]) }}`, built from the grain's columns in
  the same order they're grouped by, and name the column `<model_name>_key` (so
  `location_performance.sql` produces `location_performance_key`) - always ending in `_key`,
  never `_id`, to distinguish a generated key from a natural primary key (which is always
  `<object>_id`). A `dbt_utils.unique_combination_of_columns` test on the grain's columns is
  not a substitute for this - it can tell you the grain is unique, but the model still needs
  a real primary key column. Don't invent a different name or skip the surrogate key if the
  grain has no natural key - a missing or inconsistently-named grain key has shown up as a
  real, recurring inconsistency.
- **Materialize new marts built on top of an incremental mart (like `orders`) as incremental
  too if they share its transactional, append-only grain - this is a requirement, not a
  suggestion.** A single incremental sibling in the project has not been enough signal on its
  own; treat this as explicit, not inferred. Mart models with a daily or event grain that only
  grows forward over time (e.g. one row per location per day) should be materialized as
  `incremental`, with a `unique_key` matching the grain and a short lookback window (2-3 days)
  on the date column, using the `merge` incremental strategy. Filter every CTE that drives the
  model's grain to the same lookback window, not just one of them - filtering only a
  secondary/joined CTE while leaving the driving table unfiltered will cause `merge` to
  overwrite historical rows with incomplete data on the next incremental run. Wrap the
  lookback bound in `coalesce(..., '1900-01-01'::date)` (or similar) - without it,
  `max(order_date)` against an empty target relation returns `NULL` and the filter silently
  excludes every row instead of loading anything. Marts with a fixed, non-growing grain (like
  one row per customer or per product) stay `table`-materialized per `dbt_project.yml`
  defaults. Before making any transactional mart incremental, check for window functions that
  partition over a full entity history (e.g.
  `row_number() over (partition by customer_id order by order_date)`). Those need the
  entity's complete history to number correctly, and will silently produce wrong results once
  the source is filtered to a lookback window per run - either compute them over an unfiltered
  ref instead of the filtered import CTE, or drop the column if nothing depends on it.
- **Document basis mismatches and temporal-consistency risk explicitly, in the column
  description, whenever they exist:**
  - If a headline total and its component breakdowns use a different basis (e.g. one is
    tax-inclusive, the other isn't), say so in both columns' descriptions, even if you also
    test the relationship.
  - If a measure is derived by joining to a dimension attribute that can change over time
    (e.g. `products.product_price`, the *current* catalog price) rather than a value captured
    at transaction time, document that the figure reflects current pricing and may not match
    the actual historical transaction amount.
- Every new mart needs a `.yml` with a model description, a column description for every
  column, **at least one model-level `data_tests` entry - this is required, not optional, a
  model with only column-level tests is incomplete**, and at least one `unit_tests` case,
  matching the thoroughness of `models/marts/orders.yml` and `models/marts/customers.yml`.
  Data tests should assert something that could actually fail (a real invariant), not restate
  the model's own arithmetic. Unit tests on incremental models must set
  `overrides: macros: is_incremental: false`. On the first build of a new incremental model
  that has a unit test, `dbt build` will fail with a schema-introspection error because the
  target relation doesn't exist yet - run `dbt run --empty --select <model_name>` once first,
  then build.
- **Every mart needs `config.meta.owner` and `config.group` set to `analytics_engineering`**,
  matching every other model in `models/marts/`. See `models/marts/_groups.yml` for the group
  definition.
- This project requires the `arguments:` property on generic test definitions (see
  `dbt_project.yml`'s `require_generic_test_arguments_property` flag) - write test arguments
  like `expression:`, `to:`/`field:`, or `values:` nested under `arguments:`, not at the
  top level of the test config. The old top-level form is a parse error here, not just a
  style mismatch.

## Reusable patterns

See `.agents/skills/create-mart-model/SKILL.md` for the step-by-step pattern to follow when
building a new mart model.
