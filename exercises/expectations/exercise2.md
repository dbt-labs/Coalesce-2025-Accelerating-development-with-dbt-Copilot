# Exercise 2 - what to expect

You're checking Wizard's model against this project's actual conventions - visible in
`team_notes.md` and in the other marts - not against some abstract standard of "good
dbt." The checklist in `exercise2.md` is the same list every table should work through; what
varies is how many of those items turn out to be off.

**What's normal:** the number and kind of deviations you find will vary a lot, table to
table and run to run. Some tables will find several things worth fixing. Some will find
close to none. Both are useful, valid outcomes going into Exercise 3 - a table that finds
little isn't a sign of a weaker review, and a table that finds a lot isn't a sign Wizard did
poorly. It just means the underlying model is non-deterministic.

**A reasonable bar:** work through each item on the checklist individually rather than
skimming for whatever stands out first - some deviations (like a subtly wrong join type)
won't be obvious unless you specifically look for them.

**The preview, visualization, lineage, and `dbt compare` steps** should just work - you're
confirming that dbt Studio can surface a data preview, an in-thread chart, lineage, and a
compare summary for the new model, not evaluating Wizard's modeling choices yet.

If you don't find anything wrong, that's a legitimate result worth bringing to Exercise 3 too.
It's good material for discussing which patterns Wizard picks up reliably versus which ones
need to be written down explicitly.
