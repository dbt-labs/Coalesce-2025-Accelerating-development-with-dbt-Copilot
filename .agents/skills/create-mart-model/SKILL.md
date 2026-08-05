---
name: create-mart-model
description: Use when building a new dbt mart model in this project - covers grain selection, building on existing marts, incremental materialization, and required tests/docs.
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

3. **Aggregate before you join.** If a metric needs item-level detail (for example, splitting
   revenue by a category that varies per item within a parent record), aggregate at the
   detail grain first, then join the pre-aggregated result up to the coarser grain. Joining
   before aggregating risks fan-out and double-counted parent-level values.

4. **Choose materialization by grain behavior.** If the new mart's grain grows forward over
   time (a new row appears each day/event and old rows don't change), materialize it as
   `incremental` with:
   - `unique_key` set to the grain's columns
   - `incremental_strategy='merge'`
   - an `is_incremental()` filter with a short lookback window (2-3 days) on the date column,
     to catch any late-arriving or corrected records
   - the same lookback filter applied to **every** CTE that drives the model's grain, not
     just one of them. If the model joins two or more sources to build its grain, filtering
     only one side leaves the other side unfiltered on incremental runs, which can cause
     `merge` to overwrite historical rows with incomplete data.

   If the grain is fixed (one row per a dimension that doesn't grow, like one row per
   customer or product), leave it `table`-materialized (the project default for marts).

5. **Write the SQL to match project style.** Follow `dbt-styleguide.md`: `with` CTEs, explicit
   `as` aliases, snake_case, explicit join types, group-by-number, no short table aliases.

6. **Write the YAML.** Every model needs:
   - a model-level `description`
   - a `description` for every column
   - at least one model-level `data_tests` entry that asserts a real invariant - something
     that could actually fail (a reconciling expression across independently-derived
     components, a bound like `x <= y`, or a uniqueness-of-grain check). Don't write a test
     that just restates the model's own arithmetic (e.g. asserting `a - b = c` when `c` was
     literally computed as `a - b` in the same query) - it can never fail and catches nothing.
   - at least one `unit_tests` case with representative input/output rows. If the model is
     `materialized='incremental'`, set `overrides: macros: is_incremental: false` on the unit
     test, since dbt evaluates unit tests without an existing target relation to check
     `is_incremental()` against.

7. **Validate.** Run `dbt build --select <model_name>` and confirm it compiles, runs, and
   passes its tests before considering the model done. If the model is incremental, run it
   twice in a row and confirm row counts and historical values are unchanged after the second
   run - a filter that only covers part of the grain won't show up as a failure on the first
   run, only on the second.
