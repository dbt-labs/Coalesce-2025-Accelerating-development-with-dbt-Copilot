# Exercise 3 - Capture your standards

Practical block #3: take the requirements from Exercise 2 and wrap them into reusable tools.
Decide what should make it into an always-on instruction file, what should make it into a
task-specific skill, and what should be left as a one-off fix.

*See `expectations/exercise3.md` for what to expect - there's no single right `AGENTS.md` or
skill, just a shape that most good versions share.*

## Part 1: AGENTS.md

`AGENTS.md`, at the project root, is always-on context - dbt Wizard reads it for every
prompt in this project.

1. Create (or open) `AGENTS.md` at the project root.

2. Go through `team_notes.md` and move every rule that should always apply, regardless
   of what you're building, into `AGENTS.md`. This is the general, always-on half of
   "capture your standards" - the skill in Part 2 is for what's specific to marts.

3. Now capture anything that wasn't called out in `team_notes.md` at all, but that you
   still want Wizard to follow every time.

## Part 2: a custom skill

A skill is a reusable, task-specific instruction package - used automatically when Wizard
recognizes a matching task, or invoked explicitly in a prompt. Skills are auto-discovered at
`.agents/skills/<name>/SKILL.md`.

1. Create `.agents/skills/create-mart-model/SKILL.md`.

2. Give it a `description` in the frontmatter that says when Wizard should invoke it (e.g.
   "Use when building a new dbt mart model in this project...") - this is what Wizard
   actually matches against to decide whether to use the skill automatically, so it needs to
   be specific enough to trigger on the right kind of request, not just a label.

3. Go through the `team_notes.md` again and add all rules that specifically apply to mart models.
   Ideally, the skill has a detailed set of instructions for Wizard on how you want your mart models
   to be built but for time reasons, we simplify this to only the rules today.

Once both files exist, you have two complementary mechanisms in place: `AGENTS.md` as
always-on project context, and a skill for a specific repeatable task. Between the two of
them, everything worth keeping from `team_notes.md` should now live in whichever one it
actually belongs in. If you've moved everything that matters, the styleguide has done its
job and can be deprecated.
