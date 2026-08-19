# Exercise 1 - what to expect

There's no single correct output here, and that's the point. At this stage in the lab,
Wizard doesn't have any project-specific standards written down yet, so it's working from
nothing but the surrounding code and its own judgment. Two people running the exact same
prompt can reasonably get two different (and equally "correct") models back.

**What should come out:** a new mart with one row per location per day, covering total
revenue, order count, and a food vs. drink revenue split, plus a `.yml` file with some tests
and docs. The model name itself may vary (`daily_location_performance`,
`location_daily_performance`, and similar have all shown up).

**What's normal to see vary between runs:**
- Naming choices - count column naming, whether a generated key gets introduced and what
  it's called.
- Materialization - `table` vs. `incremental`.
- Whether item-level data gets pre-aggregated before joining, or joined in raw.
- Whether Wizard builds on top of existing marts (`orders`, `order_items`, `locations`) or
  re-derives logic from staging models or raw sources instead.
- How thorough the yml docs and tests are.

If your table's result looks meaningfully different from another table's, that doesn't mean
either of you did something wrong. Exercise 2 is where you'll evaluate the result against
this project's actual, specific conventions - not against an abstract ideal.
