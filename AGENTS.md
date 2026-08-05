# AGENTS.md

## SQL style and naming conventions

Follow `dbt-styleguide.md` for all naming, SQL styling, Jinja styling, and YAML styling
conventions in this project. Every new model must conform to it.

## Building new marts

- Before joining raw sources, check whether an existing mart or staging model already
  contains the logic you need (e.g. food/drink classification, revenue totals, customer
  lifetime metrics). Build on top of existing marts rather than re-deriving that logic from
  raw sources - it keeps business logic defined in one place and avoids accidental
  join fan-out.
- When you do need item-level detail (for example, splitting revenue by category), aggregate
  at the most granular level first, then join the aggregate up to the coarser grain. Don't
  join first and then aggregate - it's easy to double-count when a parent record (like an
  order) can match multiple categories.
- Mart models with a daily or event grain that only grows forward over time (e.g. one row per
  location per day) should be materialized as `incremental`, with a `unique_key` matching the
  grain and a short lookback window (2-3 days) on the date column, using the `merge`
  incremental strategy. Filter every CTE that drives the model's grain to the same lookback
  window, not just one of them - filtering only a secondary/joined CTE while leaving the
  driving table unfiltered will cause `merge` to overwrite historical rows with incomplete
  data on the next incremental run. Marts with a fixed, non-growing grain (like one row per
  customer or per product) stay `table`-materialized per `dbt_project.yml` defaults.
- Every new mart needs a `.yml` with a model description, a column description for every
  column, at least one `data_tests` assertion on the model as a whole (e.g. a reconciling
  expression or a uniqueness-of-grain check), and at least one `unit_tests` case, matching the
  thoroughness of `models/marts/orders.yml` and `models/marts/customers.yml`. Data tests
  should assert something that could actually fail (a real invariant), not restate the
  model's own arithmetic. Unit tests on incremental models must set
  `overrides: macros: is_incremental: false`.

## Reusable patterns

See `.agents/skills/create-mart-model/SKILL.md` for the step-by-step pattern to follow when
building a new mart model.
