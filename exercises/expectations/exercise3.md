# Exercise 3 - what to expect

There's no single right `AGENTS.md` or skill to write here. As long as yours captures the
real gaps your table found in Exercise 2, and splits them correctly between "applies to
every model" and "specific to building a mart," you're on the right track - the exact
wording and organization can look different table to table.

**The shape to expect from `AGENTS.md`:** a handful of short, thematic sections (naming and
keys, materialization, SQL structure, testing and documentation, model layering, and similar
groupings are common) with a few sentences to a short paragraph per rule - not an essay per
rule, and not a single flat list. A rule belongs here if it would matter just as much on a
staging or intermediate model as it would on a mart.

**The shape to expect from the skill:** shorter than `AGENTS.md`, and structured as an
ordered, numbered process specific to building a mart (grain, materialization, drafting the
SQL, writing the yml, validating). It should point back to `AGENTS.md` for anything already
covered there rather than restate it - if you find yourself copying a whole rule from
`AGENTS.md` into the skill, that's a sign it belongs in only one place.

**A useful test if you're unsure where something goes:** ask "would this rule matter on a
staging model too?" If yes, it belongs in `AGENTS.md`. If it's really about the process of
building a mart specifically, it belongs in the skill.

**The review-automation rule** (preview, lineage, and `dbt compare` on every model change) is
a good example of a rule that belongs in `AGENTS.md`, not the skill - it applies to any
model change, not just building a new mart.

Don't expect to get the split perfectly right on the first pass - Exercise 4 is where you'll
find out whether it actually holds up, and it's normal to come back and adjust either file
afterward.
