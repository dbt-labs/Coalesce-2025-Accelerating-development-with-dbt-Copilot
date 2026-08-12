---
name: create-mart-model
description: Use when building a new dbt mart model in this project - covers grain selection, building on existing marts, incremental materialization, join/aggregation discipline, surrogate keys, governance metadata, and required tests/docs.
---

# Creating a mart model

1. **Identify the grain.** State explicitly what one row represents (e.g. "one row per
   location per day"). Name the model to describe what it is, not how it's built (e.g.
   `location_performance`, not `location_orders_joined`).

2. **Reuse existing marts before touching raw sources.** Check `models/marts/` and
   `models/staging/` for a model that already contains the metric or classification logic you
   need. Join to that mart rather than re-deriving the same logic. This keeps business logic
   defined once and avoids duplicating (and potentially diverging from) an existing
   definition.

3. **Aggregate before you join - always, not just when it prevents a bug.** If a metric needs
   item-level detail (for example, splitting revenue by a category that varies per item within
   a parent record), aggregate at the detail grain first, in its own CTE, then join the
   pre-aggregated result up to the coarser grain. Never join a raw, un-aggregated table (like
   `order_items`) directly into the same step that does your final grouping - even when it
   doesn't cause a double-counting bug, this project requires the pre-aggregate-then-join
   structure every time.

4. **Default to `left join` for enrichment joins.** When joining a fact-grain CTE to a
   dimension/reference table purely to pull in a descriptive attribute (a location's name, a
   product's name), use `left join`. Reserve `inner join` for when you specifically want to
   filter out rows with no match. An `inner join` to a dimension table will silently drop
   fact rows on any foreign-key gap, with no test failure to catch it.

5. **Name every CTE deliberately, and name the terminal one `final`.** The CTE immediately
   before the model's final `select` must be named `final` in every model in this project -
   never named after the model itself, and never reusing an earlier CTE's name.

6. **Choose materialization by grain behavior - and treat "transactional" as a hard trigger,
   not a hint.** If the new mart's grain grows forward over time (a new row appears each
   day/event and old rows don't change) - or if it's built on top of an already-incremental
   mart (like `orders`) and shares its transactional grain - materialize it as `incremental`.
   Do not treat a single incremental sibling as optional context to weigh; treat it as a
   requirement to match. Configure:
   - `unique_key` set to the grain's columns
   - `incremental_strategy='merge'`
   - an `is_incremental()` filter with a short lookback window (2-3 days) on the date column,
     to catch any late-arriving or corrected records
   - the same lookback filter applied to **every** CTE that drives the model's grain, not
     just one of them. If the model joins two or more sources to build its grain, filtering
     only one side leaves the other side unfiltered on incremental runs, which can cause
     `merge` to overwrite historical rows with incomplete data.
   - the lookback bound wrapped in `coalesce(..., '<a safe early date>')`, e.g.
     `coalesce(dateadd(day, -3, max(order_date)), '1900-01-01'::date)`. Without this,
     `max(order_date)` against an **empty** target relation (the model's first-ever build, or
     right after `dbt run --empty`) returns `NULL`, the filter excludes every row, and the
     model silently stays empty forever instead of doing a full load.

   If the grain is fixed (one row per a dimension that doesn't grow, like one row per
   customer or product), leave it `table`-materialized (the project default for marts).

   Before making any transactional mart incremental, check for window functions partitioned
   over an entity's full history (e.g.
   `row_number() over (partition by customer_id order by order_date)`). Those need every one
   of that entity's rows to number correctly, and silently break once the source is filtered
   to a lookback window per run, since each run only sees that window's slice per entity.
   Either compute that column from an unfiltered ref, or drop it if nothing downstream depends
   on it - don't leave it computed against the filtered CTE.

7. **If the grain has no single natural key, generate a surrogate key - the same way every
   time.** Use `{{ dbt_utils.generate_surrogate_key([...]) }}` built from the grain's columns
   in the same order they're grouped by, and name the resulting column `<model_name>_key`
   (e.g. `location_performance.sql` produces `location_performance_key`) - always ending in
   `_key`, never `_id`, to distinguish a generated key from a natural primary key (which is
   always `<object>_id`). This project has no tolerance for inventing a new naming pattern
   per model - use this one.

8. **Write the SQL to match project style.** Follow `dbt-styleguide.md`. Counts are named
   `count_<noun>`, never `<noun>_count`.

9. **Document basis mismatches and temporal-consistency risk in the column description,
    whenever they exist.** If a total and its components use a different basis (tax-inclusive
    vs. not), say so in both descriptions. If a measure is built from a dimension attribute
    that can change over time (e.g. current catalog price via a join to `products`) rather
    than a value captured at transaction time, document that it reflects current pricing and
    may not match the historical transaction amount.

10. **Write the YAML.** Every model needs:
    - a model-level `description`
    - a `description` for every column
    - `config.meta.owner` and `config.group` set to `analytics_engineering` (see
      `models/marts/_groups.yml`), matching every other mart in this project
    - at least one model-level `data_tests` entry that asserts a real invariant - something
      that could actually fail (a reconciling expression across independently-derived
      components, a bound like `x <= y`, or a uniqueness-of-grain check). This is required on
      every mart, not optional - a model with only column-level tests is incomplete. Don't
      write a test that just restates the model's own arithmetic (e.g. asserting `a - b = c`
      when `c` was literally computed as `a - b` in the same query) - it can never fail and
      catches nothing.
    - at least one `unit_tests` case with representative input/output rows. If the model is
      `materialized='incremental'`, set `overrides: macros: is_incremental: false` on the unit
      test, since dbt evaluates unit tests without an existing target relation to check
      `is_incremental()` against.

11. **First build of an incremental model with a unit test: bootstrap it.** dbt needs to
    introspect the target relation's column types to validate a unit test's `expect` block. On
    the very first build, that relation doesn't exist yet, so `dbt build` fails with a
    schema-introspection error on the unit test - this is a known dbt limitation, not a bug in
    your model. Fix: run `dbt run --empty --select <model_name>` once to create the (empty)
    relation, then run `dbt build` normally. You only need to do this once per model, or again
    after dropping/recreating the table from scratch.

12. **Validate.** Run `dbt build --select <model_name>` and confirm it compiles, runs, and
    passes its tests before considering the model done. If the model is incremental, run it
    twice in a row and confirm row counts and historical values are unchanged after the second
    run - a filter that only covers part of the grain won't show up as a failure on the first
    run, only on the second.

13. **Before finishing, re-check this exact list against your own output** - naming
    (`count_` prefix, `final` CTE, `_key` surrogate key convention), join discipline
    (aggregate before join, `left join` for enrichment), materialization (incremental if
    transactional), governance metadata (`meta.owner`/`group`), and test rigor (model-level
    test, temporal/basis documentation). Every one of these has been observed to get missed
    at least once - don't assume any of them happened automatically.
