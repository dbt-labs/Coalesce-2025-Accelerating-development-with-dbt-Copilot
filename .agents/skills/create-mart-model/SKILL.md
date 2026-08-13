---
name: create-mart-model
description: Use when building a new dbt mart model in this project - the step-by-step process for grain selection, deciding materialization, drafting the SQL, and validating the result. For the actual naming/testing/materialization rules, see AGENTS.md - this skill is the mart-building workflow, not a restatement of those rules.
---

# Creating a mart model

This is the process specific to building a new mart model in this project. It assumes you
already know this project's conventions from `AGENTS.md` - this skill won't repeat them,
only tell you when and how to apply them while building a mart.

1. **Identify the grain.** State explicitly what one row represents (e.g. "one row per
   location per day"). Name the model to describe what it is, not how it's built (e.g.
   `location_performance`, not `location_orders_joined`).

2. **Decide materialization before you write any SQL.** If this mart's grain grows forward
   over time, or it's built on top of an already-incremental mart and shares its
   transactional grain, it needs to be `incremental` per `AGENTS.md`'s materialization rules.
   Decide this now - retrofitting materialization after the model already has data in the
   warehouse means a `--full-refresh` to rebuild the physical table with the new schema/config.

3. **Draft the SQL**, applying `AGENTS.md`'s naming, key, join, and aggregation rules as you
   go: primary key/surrogate key naming, `count_` prefixes, aggregate-before-join, `left
   join` for enrichment, and the `final` terminal CTE.

4. **Write the yml**: model description, column descriptions, governance config
   (`meta.owner`/`group`), and a model-level `data_tests` entry - per `AGENTS.md`'s testing
   and documentation rules. Add a `unit_tests` case if one's actually useful here (not
   required on every model).

5. **Validate.** Run `dbt build --select <model_name>` and confirm it compiles, runs, and
   passes its tests. If the model is incremental, follow `AGENTS.md`'s incremental
   validation steps: bootstrap the first build with `dbt run --empty --select <model_name>`
   if it has a unit test, then run it a second time and confirm row counts and historical
   values are unchanged.

6. **Before finishing, re-check your output against `AGENTS.md` directly, rule by rule** -
   don't rely on having remembered everything correctly from step 3 onward. Every rule in
   that file has been observed to get missed at least once.
