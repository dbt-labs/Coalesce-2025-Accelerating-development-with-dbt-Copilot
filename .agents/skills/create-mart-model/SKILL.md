---
name: create-mart-model
description: Use when building a new dbt mart model in this project - the step-by-step process for grain selection, building on existing marts, deciding materialization, and validating the result. For the actual naming/testing/materialization rules, see AGENTS.md - this skill is the mart-building workflow, not a restatement of those rules.
---

# Creating a mart model

This is the process specific to building a new mart model in this project. It assumes you
already know this project's conventions from `AGENTS.md` - this skill won't repeat them,
only tell you when and how to apply them while building a mart.

1. **Identify the grain.** State explicitly what one row represents (e.g. "one row per
   location per day"). Name the model to describe what it is, not how it's built (e.g.
   `location_performance`, not `location_orders_joined`).

2. **Reuse existing marts before touching raw sources.** Check `models/marts/` and
   `models/staging/` for a model that already contains the metric or classification logic you
   need. Join to that mart rather than re-deriving the same logic (`AGENTS.md`'s "Building
   new marts" rule).

3. **Decide materialization before you write any SQL.** If this mart's grain grows forward
   over time, or it's built on top of an already-incremental mart and shares its
   transactional grain, it needs to be `incremental` per `AGENTS.md`'s materialization rules.
   Decide this now - retrofitting materialization after the model already has data in the
   warehouse means a `--full-refresh` to rebuild the physical table with the new schema/config.

4. **Draft the SQL**, applying `AGENTS.md`'s naming, key, join, and aggregation rules as you
   go: primary key/surrogate key naming, `count_` prefixes, aggregate-before-join, `left
   join` for enrichment, and the `final` terminal CTE.

5. **If incremental and this is the model's first build with a unit test, bootstrap it.**
   dbt needs the target relation to exist to introspect its schema for the unit test's
   `expect` block, and on a brand-new model it doesn't exist yet. Run
   `dbt run --empty --select <model_name>` once, then build normally.

6. **Write the yml**: model description, column descriptions, governance config
   (`meta.owner`/`group`), a model-level `data_tests` entry, and a `unit_tests` case - per
   `AGENTS.md`'s testing and documentation rules.

7. **Validate.** Run `dbt build --select <model_name>` and confirm it compiles, runs, and
   passes its tests. If the model is incremental, run it twice in a row and confirm row
   counts and historical values are unchanged after the second run - a filter that only
   covers part of the grain won't show up as a failure on the first run, only on the second.

8. **Before finishing, re-check your output against `AGENTS.md` directly, rule by rule** -
   don't rely on having remembered everything correctly from step 4 onward. Every rule in
   that file has been observed to get missed at least once.
