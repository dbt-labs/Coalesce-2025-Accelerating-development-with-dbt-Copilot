# Exercise 4 - See the payoff, round 1

Practical block #4: delete the mart and rebuild it from scratch, now that your standards are
captured, and compare against what you found in Exercise 2.

1. Delete `models/marts/location_performance.sql` and `models/marts/location_performance.yml`.

2. Start a brand new dbt Wizard session (a fresh chat, so nothing from the earlier
   conversation is still in context).

3. Use the exact same prompt from Exercise 1:

<ul>
Our store managers want a daily view of how each location is performing:
total revenue, number of orders, and how much of that revenue comes from
food vs. drinks. Can you build us a model for that, with tests and docs?
</ul>

4. Compare the result against your Exercise 2 findings. Did Wizard build on existing marts
   this time? Does the food/drink split avoid double-counting? Is materialization handled
   correctly? Does the YAML meet the bar you set?

5. If anything still isn't right, that's useful signal too - it means your `AGENTS.md` or
   skill needs to be more specific. Refine it and try again.
