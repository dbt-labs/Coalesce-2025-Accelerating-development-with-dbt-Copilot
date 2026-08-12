## Naming fields and tables

- Every model must have a single-column primary key. If the grain has a natural single
  column key, name it `<object>_id` (for example, `account_id`). If the grain has no natural
  single-column key (for example, a grain of one row per location per day), generate a
  surrogate key - see below. Testing uniqueness across a combination of columns (e.g.
  `dbt_utils.unique_combination_of_columns`) is not a substitute for having an actual primary
  key column; every model needs one either way.
- Counts should be prefixed with `count_` (for example, `count_orders`), not suffixed (avoid `orders_count`).
- Surrogate/generated keys (for example, keys built with `dbt_utils.generate_surrogate_key`) should always be named `<model_name>_key` (for example, `location_performance_key`), not `<model_name>_id`. This distinguishes a generated key from a natural primary key, which is always named `<object>_id`.

## Styling SQL

- Aggregations should be executed as early as possible (on the smallest data set possible) before joining to another table. Never join a raw, un-aggregated table (like `order_items`) directly into the same step that does your final grouping - pre-aggregate it to its own grain in a dedicated CTE first.
- When joining a fact-grain CTE to a dimension/reference table purely to enrich it with a descriptive attribute (for example, joining to `locations` for `location_name`), default to `left join`. Only use `inner join` when you specifically want to filter out rows with no match.
- The final CTE in a model - the one immediately before the closing `select` - should always be named `final`. Never name it after the model itself, and never reuse an earlier CTE's name.

## Mart model requirements

- Every mart model must set `config.meta.owner` and `config.group` in its yml, identifying
  the team that owns it. See `models/marts/_groups.yml` for the group definition and any
  existing mart's yml for the pattern.
- Transactional, append-mostly models (one row per event, e.g. `orders`) should be
  materialized as `incremental`, not `table`. See `models/marts/orders.sql` for the reference
  implementation.
- Every mart model must include at least one model-level `data_tests` entry that asserts a
  real invariant (a reconciling expression across independently-derived components, a bound,
  or a uniqueness-of-grain check). Column-level tests alone are not sufficient.
