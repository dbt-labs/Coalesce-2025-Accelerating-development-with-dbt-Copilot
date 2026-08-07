# Exercise 5 - Do the whole cycle again

Practical block #5: a new task, start to finish. Let's see the whole loop - prompt, review,
capture (if needed), accelerate - run through again on a different business question.

1. Start a new dbt Wizard session and prompt with a new business request:

<ul>
Our category managers want to see product performance by day: revenue,
number of orders, and margin (item price minus supply cost) for each
product. Can you build us a model for that, with tests and docs?
</ul>

   This is the first time `product_performance` is built. If it comes back incremental with a
   unit test and the build fails on a schema-introspection error, that's the same bootstrap
   step from Exercise 1: run `dbt run --empty --select product_performance`, then build again.

2. Review the output the same way you did in Exercise 2: preview the data, check the
   lineage, and compare it against `dbt-styleguide.md` and your `AGENTS.md`.

3. Notice how much (or how little) correction this required compared to Exercise 1. The
   `create-mart-model` skill and `AGENTS.md` you wrote in Exercise 3 apply here too, even
   though this is a different business question - that's the point of capturing a pattern
   instead of a one-off fix.

4. If you do find something new to capture, add it to `AGENTS.md` or the skill now. Standards
   compound: every gap you close makes the next task faster without sacrificing quality.
