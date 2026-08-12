## Naming fields and tables
- The primary key of a model should be named `<object>_id`, for example, `account_id`. This makes it easier to know what `id` is being referenced in downstream joined models.
- Consistency is key! Use the same field names across models where possible. For example, a key to the `customers` table should be named `customer_id` rather than `user_id` or `id`.
- Do not use abbreviations when naming fields. Emphasize readability over brevity. For example, do not use `cust` for `customer` or `o` for `orders`.
- Avoid reserved words as column names.
- Booleans should be prefixed with `is_` or `has_`.
- Counts should be prefixed with `count_` (for example, `count_orders`), not suffixed (avoid `orders_count`).
- Surrogate/generated keys (for example, keys built with `dbt_utils.generate_surrogate_key`) should always be named `<model_name>_key` (for example, `location_performance_key`), not `<model_name>_id`. This distinguishes a generated key from a natural primary key, which is always named `<object>_id`.
- Timestamp columns should be named `<event>_at`(for example, `created_at`) and should be in UTC. If a different timezone is used, this should be indicated with a suffix (`created_at_pt`).
- Dates should be named `<event>_date`. For example, `created_date.`
- Table, CTE, and column names should be written in `snake_case`.

## Styling SQL
- Use trailing commas.
- Indents should be four spaces.
- Field names, keywords, and function names should all be lowercase.
- The `as` keyword should be used explicitly when aliasing a field or table.
- Grouped fields should be stated before aggregates and window functions in the select list
- Aggregations should be executed as early as possible (on the smallest data set possible) before joining to another table to improve performance.
- Ordering and grouping by a number (eg. group by 1, 2) is preferred over listing the column names explicitly
- Prefer `union all` to `union` unless you explicitly want to remove duplicates.
- If joining two or more tables, _always_ qualify your column names with the relevant table name. If only selecting from one table, qualification is not needed.
- Be explicit about your join type (i.e. write `inner join` instead of `join`).
- Do not use right joins ever. Do not use full outer joins unless you really need to.
- When joining a fact-grain CTE to a dimension/reference table purely to enrich it with a descriptive attribute (for example, joining to `locations` for `location_name`), default to `left join`. Only use `inner join` when you specifically want to filter out rows with no match - an `inner join` to a dimension table will silently drop fact rows on any foreign-key gap.
- All references to other dbt models, seed, or snapshots should use the {{ ref() }} dbt function
- All references to dbt sources should use the {{ source() }} dbt function
- Do not use or call dbt macros unless you are explicitly instructed to
- Do not re-alias CTE names.
- Do not use short table aliases like `select * from orders as o` -- always prefer longer, explicit table aliases or no aliases at all. `select * from orders` is better. 
- Do not include semicolons (;) to end SQL statements like `select 1 as id;` -- always prefer syntax without like `select 1 as id`
- The final CTE in a model - the one immediately before the closing `select` - should always be named `final`. Never name it after the model itself, and never reuse an earlier CTE's name.

## Styling Jinja
- When using Jinja delimiters, use spaces on the inside of your delimiter, like `{{ this }}` instead of `{{this}}`

## Styling YAML

- Indents should be two spaces
- List items should be indented
- Use a new line to separate list items that are dictionaries where appropriate

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
