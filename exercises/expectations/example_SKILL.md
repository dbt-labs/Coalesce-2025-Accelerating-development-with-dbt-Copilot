<!--
This is one worked example of a create-mart-model skill for this project, not the only
correct version. It's provided as a reference point for Exercise 3 - useful to compare
against once you've written your own, not something to copy before you've tried it yourself.
-->

---
name: create-mart-model
description: Use when building a new dbt mart model in this project - the step-by-step process for grain selection, materialization, drafting the SQL, the yml requirements specific to marts (governance metadata, model-level tests), and validating the result. General rules that apply to every model, regardless of type, live in AGENTS.md instead.
---

# Creating a mart model

This is the process specific to building a new mart model in this project. It assumes you
already know this project's conventions from `AGENTS.md` - this skill won't repeat them,
only tell you when and how to apply them while building a mart, and adds the requirements
specific to marts.

1. **Identify the grain.** State explicitly what one row represents (e.g. "one row per
   location per day"). Name the model to describe what it is, not how it's built (e.g.
   `daily_location_performance`, not `location_orders_joined`).

2. **Decide materialization before you write any SQL.** If this mart's grain grows forward
   over time, or it's built on top of an already-incremental mart and shares its
   transactional grain, it needs to be `incremental` per `AGENTS.md`'s materialization rules.
   Decide this now - retrofitting materialization after the model already has data in the
   warehouse means a `--full-refresh` to rebuild the physical table with the new schema/config.

3. **Write the yml.** Every mart needs:
   - A model description and a column description for every column, matching the
     thoroughness of `models/marts/orders.yml` and `models/marts/customers.yml`.
   - `config.meta.owner` and `config.group` set to `analytics_engineering`, matching every
     other model in `models/marts/`. See `models/marts/_groups.yml` for the group definition.
   - At least one model-level `data_tests` entry - declared under the model's top-level
     `data_tests:` key, not nested under a column - that could actually catch a real bug.
     Write a check that reconciles independently-computed values against each other, for
     example `order_items_subtotal = subtotal` (`orders.yml`). This is required, not
     optional - a mart with only column-level tests is incomplete. Don't write a test that
     just restates the model's own arithmetic (e.g. asserting `a - b = c` when `c` was
     literally computed as `a - b` in the same query) - it can never fail and catches
     nothing.

4. **Before finishing, re-check your output against `AGENTS.md` and step 3 above, rule by
   rule** - don't rely on having remembered everything correctly from earlier steps. Every
   rule in `AGENTS.md`, and every requirement in step 3, has been observed to get missed at
   least once.
