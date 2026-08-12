# Exercise 3 - Capture your standards

Practical block #3: take the requirements from Exercise 2 and wrap them into reusable tools.
Decide what should make it into an always-on instruction file, what should make it into a
task-specific skill, and what should be left as a one-off fix.

## Part 1: AGENTS.md

`AGENTS.md`, at the project root, is always-on context - dbt Wizard reads it for every
prompt in this project.

1. Create (or open) `AGENTS.md` at the project root.

2. Capture the general, always-applicable conventions first: point to `dbt-styleguide.md`
   for naming, SQL style, Jinja style, and YAML style, so Wizard treats it as required, not
   optional.

3. Now capture what you actually learned in Exercise 2 that isn't already written down
   anywhere: for example, "build on top of existing marts instead of re-deriving logic from
   raw sources" and "aggregate item-level detail before joining it up to a coarser grain, to
   avoid double-counting." If you found a materialization issue, capture the rule for when a
   mart should be incremental vs. a table.

4. Re-prompt Wizard with the same Exercise 1 request (in a fresh chat, if you want a clean
   test) and see whether the new model comes into line without you correcting it by hand.

## Part 2: a custom skill

A skill is a reusable, task-specific instruction package - used automatically when Wizard
recognizes a matching task, or invoked explicitly in a prompt. Skills are auto-discovered at
`.agents/skills/<name>/SKILL.md`.

1. Create `.agents/skills/create-mart-model/SKILL.md`.

2. Write it as a step-by-step pattern for building a new mart model in this project: how to
   pick the grain, when to build on an existing mart vs. a raw source, when to aggregate
   before joining, when to go incremental, and what the YAML needs to include (descriptions,
   at least one real data test, at least one unit test).

3. Be specific about anything you had to correct by hand in Exercise 2 - a skill is only
   useful if it captures the actual mistake, not a generic reminder.

Once both files exist, you have two complementary mechanisms in place: AGENTS.md as
always-on project context, and a skill for a specific repeatable task. Move on to Exercise 4
to see whether they pay off.
