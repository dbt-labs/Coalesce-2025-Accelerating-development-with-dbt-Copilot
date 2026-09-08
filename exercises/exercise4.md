# Exercise 4 - See the payoff, round 1

Practical block #4: delete the mart and rebuild it from scratch, now that your standards are
captured, and compare against what you found in Exercise 2.

*_Note: Your model name might be different and needs to be adjusted in the following exercises._*

1. Delete `models/marts/daily_location_performance.sql` and `models/marts/daily_location_performance.yml`.
   Drop the table in your DEV schema using the `--sql` flag in `dbt run-operation` (swap in your model's actual name if
   Wizard named it something other than `daily_location_performance`):\
   `dbt run-operation --sql "drop table if exists {{ target.database }}.{{ target.schema }}.daily_location_performance"`\

2. Start a brand new dbt Wizard session (a fresh chat, so nothing from the earlier
   conversation is still in context).

3. Use the exact same prompt from Exercise 1:

<ul>
Our store managers want a daily view of how each location is performing:
total revenue, number of orders, and how much of that revenue comes from
food vs. drinks. Can you build us a model for that, with tests and docs?
</ul>

4. Compare the result against your Exercise 2 findings. Does the new model + YAML file adhere to 
   the new rules we set?

5. If anything still isn't right, that's useful signal too - it means your `AGENTS.md` or
   skill needs to be more specific. Refine it and try again.
