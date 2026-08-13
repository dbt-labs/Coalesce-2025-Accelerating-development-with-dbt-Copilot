# Exercise 3 - Capture your standards

Practical block #3: take the requirements from Exercise 2 and wrap them into reusable tools.
Decide what should make it into an always-on instruction file, what should make it into a
task-specific skill, and what should be left as a one-off fix.

## Part 1: AGENTS.md

`AGENTS.md`, at the project root, is always-on context - dbt Wizard reads it for every
prompt in this project.

1. Create (or open) `AGENTS.md` at the project root.

2. Capture the general, always-applicable conventions first: go to `dbt-styleguide.md`
   and extract all the rules that you always want Wizard to follow.

3. Now, capture anything that wasn't called out in the `dbt-styleguide.md` that you still
   want to be included.

## Part 2: a custom skill

A skill is a reusable, task-specific instruction package - used automatically when Wizard
recognizes a matching task, or invoked explicitly in a prompt. Skills are auto-discovered at
`.agents/skills/<name>/SKILL.md`.

1. Create `.agents/skills/create-mart-model/SKILL.md`.

2. Write it as a step-by-step pattern for building a new mart model in this project: how to
   pick the grain, when to build on an existing mart vs. a raw source, when to aggregate
   before joining, when to go incremental, and what the YAML needs to include (descriptions,
   at least one real data test). Check the `dbt-styleguide.md` for mart-specific rules that
   you can include here.

Once both files exist, you have two complementary mechanisms in place: AGENTS.md as
always-on project context, and a skill for a specific repeatable task. Move on to Exercise 4
to see whether they pay off.
