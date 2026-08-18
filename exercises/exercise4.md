# Exercise 4 - See the payoff, round 1

Practical block #4: delete the mart and rebuild it from scratch, now that your standards are
captured, and compare against what you found in Exercise 2.

*See `expectations/exercise4.md` for what to expect - a visible improvement, not necessarily
a perfect one.*

*_Note: Your model name might be different and needs to be adjusted in the following exercises._*

1. Delete `models/marts/location_performance.sql` and `models/marts/location_performance.yml`.

2. Deleting the files doesn't drop the underlying table. If Wizard materialized
   `location_performance` as `incremental`, the old table is still sitting in your schema, and
   the next build would incrementally merge into leftover data rather than starting fresh.\
   Drop it using the `--sql` flag in `dbt run-operation` (swap in your model's actual name if
   Wizard named it something other than `location_performance`):\
   `dbt run-operation --sql "drop table if exists {{ target.database }}.{{ target.schema }}.location_performance"`\

3. Start a brand new dbt Wizard session (a fresh chat, so nothing from the earlier
   conversation is still in context).

4. Use the exact same prompt from Exercise 1:

<ul>
Our store managers want a daily view of how each location is performing:
total revenue, number of orders, and how much of that revenue comes from
food vs. drinks. Can you build us a model for that, with tests and docs?
</ul>

5. If this build fails on a unit test with a schema-introspection error, that's the same known
   dbt limitation from Exercise 1: unit tests on incremental models need the target table to
   exist first. Wizard will figure this out! If it doesn't, run
   `dbt run --empty --select <model_name>` yourself, then build again.

6. Compare the result against your Exercise 2 findings. Does the new model + YAML file adhere to 
   the new rules we set?

7. If anything still isn't right, that's useful signal too - it means your `AGENTS.md` or
   skill needs to be more specific. Refine it and try again.
