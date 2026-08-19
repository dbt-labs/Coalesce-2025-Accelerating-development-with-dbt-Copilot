# The worst-case example

`daily_location_performance_worst_case_example.sql`/`.yml` in this folder are a deliberately
broken mart, hitting every standard captured in `AGENTS.md` and `SKILL.md` on this branch, in
one file. Built for instructor use - a live "here's what happens if none of this gets
captured" walkthrough, or a talking point if a table's Exercise 2 findings feel thin.

**These files live outside `models/`, on purpose.** They're plain text here, not part of the
dbt DAG - dbt will not parse or build them from this location. If you want to actually run
them live, copy both files into `models/marts/`, run `dbt run --select
daily_location_performance_worst_case_example --empty` once (see below for why), then `dbt build`.
Delete them from `models/marts/` again afterward - don't leave them in the real project.

## What's wrong, and where

| # | Violation | Where in the file |
|---|-----------|-------------------|
| 1 | `order_count` instead of `count_orders` | `select` list in the final CTE |
| 2 | Terminal CTE named after the model itself, not `final` | the CTE name itself |
| 3 | Raw `order_items` joined directly into the final grouping step, never pre-aggregated | the `from`/`inner join order_items` |
| 4 | `inner join` to a dimension table (`locations`) instead of `left join` | the `inner join locations` line |
| 5 | Incremental filter applied to only one of two driving CTEs, with no `coalesce()` safety net | the `orders` CTE's `is_incremental()` block - `order_items` has none at all |
| 6 | Surrogate key named `..._id` instead of `..._key` | `daily_location_performance_worst_case_example_id` |
| 7 | No model-level `data_tests` at all | the yml has only column-level tests |
| 8 | No `config.meta.owner`/`config.group` | absent from the yml entirely |
| 9 | Basis mismatch (tax-inclusive `total_revenue` vs. pre-tax `food_revenue`/`drink_revenue`) left undocumented | column descriptions in the yml |

## Two things worth calling out live, beyond the checklist

**#3 and #5 aren't just style violations - they produce actually wrong numbers, live.**
Verified by actually building this model:

- Because `order_items` is joined in before aggregating, a multi-item order's `order_total`
  gets summed once per item instead of once per order. In the unit test fixture (order 1 has
  two items, order 2 has one), `total_revenue` comes out to **33.00** instead of the correct
  **19.80** - purely from the join fan-out, nothing to do with the numbers being fake.
- The broken incremental filter was confirmed live: after bootstrapping with
  `dbt run --empty`, a normal `dbt build` run reported **success**, with the table left at
  **zero rows**. No error, no warning - `max(order_date)` against the empty table is `NULL`,
  the filter excludes everything, and the model silently never loads real data. This is the
  single most dangerous failure mode in this whole example, because nothing about the run
  output tells you it happened.

**The unit test passes anyway.** Its `expect` values were derived from the model's own
(buggy) output, not independently verified arithmetic - the same trap it's easy to fall into
in real life by copying a query's actual output into a test fixture instead of reasoning
about what the numbers should be. A passing unit test here only proves the SQL is internally
consistent with itself, not that the business logic is correct. Worth pointing out if a table
assumes "the tests pass" means "the model is right."
