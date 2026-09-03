# Exercise 2 - Review the changes

Practical block #2: check if Wizard's output model matches our specific modeling
requirements. If there are any violations, fix them.

*_Note: Your model name might be different and needs to be adjusted in the following exercises._*

1. With `daily_location_performance` open, ask Wizard to preview the resulting data.

<ul>
Show me a preview of daily_location_performance.
</ul>

2. Ask Wizard to visualize the data, right in the thread.

<ul>
Visualize monthly total_revenue by location. Return only an in-thread ASCII horizontal bar chart, with months on the y-axis and aggregated revenue on the x-axis. Use a separate bar for each location and include a legend.
</ul>

3. Ask Wizard to show you where this model sits in the DAG.

<ul>
Show me the lineage for daily_location_performance.
</ul>

4. Ask Wizard to run a `dbt compare` and show you the results.

<ul>
Run a dbt compare on daily_location_performance and show me the results.
</ul>

5. Confirm the data itself looks right at a glance: does revenue look plausible per
   location? Does the food/drink split look plausible? Would you trust this if a store
   manager saw it tomorrow?

6. Now look closer, and compare the model against `team_notes.md` and against the
   project's other marts. Wizard infers standards from surrounding files, but there can be
   inconsistencies, and not everything that's written down actually gets followed. Work
   through this list - Wizard's actual output will vary run to run, so not everything below
   will necessarily be off, but check each one specifically rather than skimming for
   whatever stands out:

   - **Count columns** - is every count-style column named `count_<noun>` (e.g.
     `count_orders`), or did it come out as `<noun>_count`?
   - **The last CTE** - open the model and look at the CTE immediately before the final
     `select`. Is it named `final`, or something else (including the model's own name)?
   - **Generated keys** - if the model introduces a surrogate/generated key (look for
     `dbt_utils.generate_surrogate_key`), does the column name end in `_key`, or `_id`?
   - **Aggregation order** - find where `order_items` (or any raw, item-level data) is used.
     Is it aggregated to its own grain in a dedicated CTE *before* being joined to anything
     else, or is it joined in raw and grouped directly to the model's final grain in one step?
   - **Join type to `locations`** - is it `left join` or `inner join`? Compare to how
     `order_items.sql`, `orders.sql`, and `customers.sql` join to their reference tables.
   - **Materialization** - open `dbt_project.yml`'s defaults and `orders.sql` for comparison.
     Is this new mart a plain `table`, or `incremental` like `orders`? If it did go
     incremental, check the lookback filter: is it applied to every CTE that drives the
     grain, and does it have a fallback (e.g. `coalesce`) for when the target table is empty?
   - **Model-level tests** - open the yml. Is there at least one test under a top-level
     `data_tests:` key (not nested under a column), or only column-level tests?
   - **yml config** - compare this model's yml side by side with `customers.yml` or
     `orders.yml`. Does it set `config.group` and `config.meta.owner` the same way?
   - **What it's built on** - did Wizard build on top of existing marts (`orders`,
     `order_items`, `locations`), or did it re-join raw sources/staging models and re-derive
     logic (like food/drink classification) that already exists elsewhere?

7. If you find violations, ask Wizard to fix them, or fix them yourself. Either way, you're
   about to turn these findings into something reusable - keep a running list.
