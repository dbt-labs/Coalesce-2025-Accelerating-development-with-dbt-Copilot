## Naming and keys

- Every model must have a single-column primary key. If the grain has a natural single
  column key, name it `<object>_id` (for example, `account_id`). If the grain has no natural
  single-column key (for example, a grain of one row per location per day), generate a
  surrogate key with `{{ dbt_utils.generate_surrogate_key([...]) }}`, built from the grain's
  columns in the same order they're grouped by, and name the column `<model_name>_key` (so
  `location_performance.sql` produces `location_performance_key`) - always ending in `_key`,
  never `_id`, to distinguish a generated key from a natural primary key. A
  `dbt_utils.unique_combination_of_columns` test on the grain's columns is not a substitute
  for this - it can tell you the grain is unique, but the model still needs a real primary
  key column. Don't invent a different name or skip the surrogate key if the grain has no
  natural key.
- Counts are prefixed `count_<noun>` (e.g. `count_orders`), never suffixed
  (`orders_count`). Check every aggregate/count column name against this before finishing a
  model.

## Governance

- Every mart needs `config.meta.owner` and `config.group` set to `analytics_engineering`,
  matching every other model in `models/marts/`. See `models/marts/_groups.yml` for the
  group definition.

## Materialization

This applies to any model, not just marts - staging and intermediate models can be
incremental too if their grain warrants it.

- Materialize a model built on top of an incremental model (like `orders`) as incremental
  too if it shares that transactional, append-only grain - this is a requirement, not a
  suggestion. A single incremental sibling in the project has not been enough signal on its
  own; treat this as explicit, not inferred. Models with a daily or event grain that only
  grows forward over time (e.g. one row per location per day) should be materialized as
  `incremental`, with a `unique_key` matching the grain (ideally the model's own primary key
  column) and a short lookback window (2-3 days) on the date column, using the `merge`
  incremental strategy.
- Filter every CTE that drives the model's grain to the same lookback window, not just one of
  them - filtering only a secondary/joined CTE while leaving the driving table unfiltered will
  cause `merge` to overwrite historical rows with incomplete data on the next incremental run.
- Wrap the lookback bound in `coalesce(..., '1900-01-01'::date)` (or similar) - without it,
  `max(order_date)` against an empty target relation returns `NULL` and the filter silently
  excludes every row instead of loading anything.
- Models with a fixed, non-growing grain (like one row per customer or per product) stay
  `table`-materialized per `dbt_project.yml` defaults.
- Before making any transactional model incremental, check for window functions that
  partition over a full entity history (e.g. `row_number() over (partition by customer_id
  order by order_date)`). Those need the entity's complete history to number correctly, and
  will silently produce wrong results once the source is filtered to a lookback window per
  run - either compute them over an unfiltered ref instead of the filtered import CTE, or
  drop the column if nothing depends on it.
- If an incremental model has a unit test, its first-ever build will fail with a
  schema-introspection error - dbt needs the target relation to exist to check its schema
  against the unit test's `expect` block, and on a brand-new model it doesn't yet. Run
  `dbt run --empty --select <model_name>` once first, then build normally. This only comes
  up if the model has a unit test in the first place; not every model needs one.
- After building an incremental model, run it a second time and confirm row counts and
  historical values are unchanged - a lookback filter that only covers part of the grain
  won't show up as a failure on the first run, only on the second.

## SQL structure

- Never join a raw, un-aggregated table directly into the same step that does your final
  grouping. If you need item-level detail (e.g. `order_items`) to compute a metric at a
  coarser grain (e.g. per location per day), aggregate the item-level data to its own grain in
  a dedicated CTE first, then join that pre-aggregated CTE up to the coarser grain. This
  applies even when joining first doesn't cause a double-counting bug - it's a required
  pattern in this project, not just a performance nice-to-have.
- Default to `left join` when enriching a fact-grain CTE with a dimension/reference table
  (e.g. joining to `locations` for `location_name`, or `products` for `product_name`). Only
  use `inner join` when you specifically intend to filter out unmatched rows. Every existing
  model in this project that does this (`order_items`, `orders`, `customers`) enriches with
  `left join` - an `inner join` here will silently drop fact rows on any foreign-key gap,
  which won't show up as a test failure.
- The terminal CTE - the one immediately before the final `select` - is always named `final`
  in every model in this project. Never name it after the model itself (e.g. don't name the
  last CTE in `location_performance.sql` `location_performance`) and never reuse an earlier
  CTE's name.

## Testing and documentation

- Every new model needs a `.yml` with a model description and a column description for
  every column, matching the thoroughness of `models/marts/orders.yml` and
  `models/marts/customers.yml`.
- Every model needs at least one model-level `data_tests` entry - declared under the
  model's top-level `data_tests:` key, not nested under a column - that could actually catch
  a real bug. Write a check that reconciles independently-computed values against each
  other, for example `total_margin <= total_revenue` (`product_performance.yml`). This is
  required on every model, not optional - a model with only column-level tests is incomplete.
  If a model genuinely has nothing to reconcile, a `dbt_utils.unique_combination_of_columns`
  check on the grain is an acceptable fallback, but treat it as a last resort, not the goal.
  Don't write a test that just restates the model's own arithmetic (e.g. asserting
  `a - b = c` when `c` was literally computed as `a - b` in the same query) - it can never
  fail and catches nothing.
- Unit tests aren't required on every model - write one where it's actually useful. If you
  do write a `unit_tests` case for a model that's `materialized='incremental'`, set
  `overrides: macros: is_incremental: false` on it - dbt evaluates unit tests without an
  existing target relation, so without the override the model's `is_incremental()` branch
  won't behave the way you expect. (See the Materialization section above for the separate
  first-build bootstrap step this can also require.)
- Document basis mismatches and temporal-consistency risk explicitly, in the column
  description, whenever they exist:
  - If a headline total and its component breakdowns use a different basis (e.g. one is
    tax-inclusive, the other isn't), say so in both columns' descriptions, even if you also
    test the relationship.
  - If a measure is derived by joining to a dimension attribute that can change over time
    (e.g. `products.product_price`, the *current* catalog price) rather than a value captured
    at transaction time, document that the figure reflects current pricing and may not match
    the actual historical transaction amount.

## Model layering

- Only staging models (`stg_*`) reference `{{ source(...) }}`. Every other model - marts and
  any intermediate models - must be built with `{{ ref(...) }}` on staging models,
  intermediate models, or other marts. Never join directly to a raw source outside of a
  staging model, even if it seems more direct.
- Before re-deriving logic that might already exist, check whether an existing mart or
  staging model already contains it (e.g. food/drink classification, revenue totals,
  customer lifetime metrics). Build on top of that rather than duplicating the logic - it
  keeps business logic defined in one place and avoids accidental join fan-out.

## Reusable patterns

See `.agents/skills/create-mart-model/SKILL.md` for the mart-building workflow - the order
to make these decisions in, and when to apply each rule above. It assumes you already know
the rules in this file; it won't repeat them.
