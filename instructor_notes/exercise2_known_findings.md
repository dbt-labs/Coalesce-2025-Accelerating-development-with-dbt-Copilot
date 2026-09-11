# Exercise 2 answer key - known findable differences

**Instructor-only.** This is not attendee-facing and should not be included in the branch
handed to workshop attendees. It exists to help you recognize what learners might find during
Exercise 2 (and to know what to nudge them toward if a table is stuck), based on repeated live
test runs of Exercise 1's prompt against dbt Wizard.

Wizard's actual output varies run to run - a given session may hit some, none, or different
combinations of these. None of this is guaranteed to reproduce live; it's what's been observed
across multiple independent test runs of the same prompt, not a deterministic script.

## Confirmed recurring gaps (found in multiple independent runs)

1. **Count column naming.** `order_count` instead of `count_orders`. Written in
   `team_notes.md`; has not been followed in any observed run.
2. **Terminal CTE naming.** The last CTE before the final `select` should be named `final`
   (see any existing mart). Observed inconsistently - sometimes correct, sometimes named after
   the model itself (e.g. a model called `location_daily_performance` with a CTE of the same
   name).
3. **Aggregate-before-join.** Raw `order_items` joined directly into the same step that does
   the final location/date grouping, instead of being pre-aggregated to its own grain in a
   separate CTE first. Written in `team_notes.md` ("aggregations should be executed as
   early as possible... before joining"). Doesn't always produce a wrong number in this
   dataset, but it's a real, checkable structural deviation.
4. **Materialization.** New marts built on transactional data have not reliably gone
   `incremental` on their own, even with `orders.sql` sitting right there as a live example
   and a written rule in `team_notes.md`. If a run *does* go incremental, check two things
   specifically: whether the lookback filter is applied to every CTE that drives the grain
   (not just one side of a join), and whether it's safe against an empty target relation
   (`max(order_date)` from an empty table is `NULL`, which can silently exclude every row
   forever rather than loading anything - the same class of bug is documented and fixed in
   `daily_location_performance.sql`, but not in `AGENTS.md`/`SKILL.md`'s
   predecessor form, so a fresh Wizard session has no way to know about it except by
   inference).

## Gaps found at least once

5. **Surrogate key naming.** `dbt_utils.generate_surrogate_key()` introduced unprompted, with
   a different key name each time it happened (`location_daily_performance_id` vs.
   `daily_daily_location_performance_id`). No fixed convention existed until it was added to
   `team_notes.md` after these runs (should now be `<model_name>_key`).
6. **Enrichment join type.** One run used `inner join` to `locations` rather than `left join`.
   Dormant in this dataset (no orders with an unmatched `location_id`), but it would silently
   drop fact rows on any foreign-key gap, and every other mart in the project enriches with
   `left join`.
7. **Missing model-level `data_tests`.** One run shipped a model with only column-level tests
   and no model-level assertion at all, despite the model's own description making a claim
   (about revenue reconciling to a subtotal) that nothing tested.

## What has reliably worked (worth noting if a table finds nothing wrong here)

- **Governance metadata.** Once `config.meta.owner`/`config.group` were added identically
  across every existing mart's yml (a 100%-consistent pattern, never written down anywhere),
  a new mart picked up the exact same config unprompted. This is good material for the
  "capture your standards" discussion: a rule written only in `team_notes.md` (not an
  auto-read file) was never followed across any run, but a pattern consistent across *every*
  sibling file was picked up without being written anywhere. That contrast is the point of
  Exercise 3 - if a table's group didn't find much wrong, this is worth surfacing as a
  positive example of standards propagating through code, not prose.
- **Avoiding the original double-counting trap.** Every observed run correctly avoided
  computing food/drink revenue from order-level totals (which would double-count an order
  containing both). This one you likely won't see recur - flag it if you do.
- **Basis/documentation honesty.** More than one run correctly called out, in the column
  descriptions, when a total and its components used different bases (tax-inclusive vs. not)
  or relied on a current catalog price rather than a captured transaction-time value. Worth
  praising if a table's model does this - it's a genuinely sophisticated catch, not just
  compliance with a rule.

## Why this list exists

Most of the "confirmed recurring gaps" and "found at least once" items above are now an
explicit, written requirement in `AGENTS.md` and `.agents/skills/create-mart-model/SKILL.md`
on this (the answer-key) branch - both files are intentionally trimmed to just
`team_notes.md`'s content plus the review-automation rule, so they stay close to what a
table would realistically produce in the time available. The empty-target-relation detail
in item 4 is the one exception: it's a real risk, but it isn't written down anywhere on
this branch either, which is itself worth pointing out if it comes up. Exercise 3 has
learners write their own version of both
files based on what they personally find - this list is your reference for what's *likely*
findable, not a script for what they must find. Let them discover it; use this to know
whether a table's list is on the right track or has missed something worth a nudge.
