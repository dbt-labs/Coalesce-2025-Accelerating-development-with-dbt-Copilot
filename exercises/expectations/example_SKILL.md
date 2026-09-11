<!--
This is one worked example of a create-mart-model skill for this project, not the only
correct version. It's provided as a reference point for Exercise 3 - useful to compare
against once you've written your own, not something to copy before you've tried it yourself.
-->

---
name: create-mart-model
description: Use when building a new dbt mart model.
---

# Creating a mart model

Assumes you already know this project's conventions from `AGENTS.md` - this skill adds
the process and requirements specific to building a mart.

1. **Identify the grain.** State explicitly what one row represents (e.g. "one row per
   location per day"). Name the model to describe what it is, not how it's built.

2. **Decide materialization before writing any SQL**, per `AGENTS.md`'s materialization
   rule.

3. **Write the yml.** Every mart needs:
   - A model description and a column description for every column.
   - `config.meta.owner` and `config.group` set, matching every other model in
     `models/marts/`. See `models/marts/_groups.yml`.
   - At least one model-level `data_tests` entry that could actually catch a real bug.

4. **Before finishing, re-check your output against `AGENTS.md` and step 3 above.**
