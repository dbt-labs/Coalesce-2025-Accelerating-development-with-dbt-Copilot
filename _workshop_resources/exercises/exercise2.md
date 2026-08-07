# Exercise 2 - Review the changes

Practical block #2: check if Wizard's output model matches our specific modeling
requirements. If there are any violations, fix them.

1. With `location_performance` open, ask Wizard to preview the resulting data.

<ul>
Show me a preview of location_performance.
</ul>

2. Ask Wizard to show you where this model sits in the DAG.

<ul>
Show me the lineage for location_performance, including column-level lineage.
</ul>

3. Confirm the data itself looks right at a glance: does revenue look plausible per
   location? Does the food/drink split look plausible? Would you trust this if a store
   manager saw it tomorrow?

4. Now look closer, and compare the model against `dbt-styleguide.md`. Wizard infers
   standards from surrounding files, but there can be inconsistencies. Things worth checking
   (this is not an exhaustive list - Wizard's actual output will vary, so look for whatever
   doesn't match, not just the items below):

   - **CTE structure and naming** - does it match the `with ... as (\n\n    select ...\n\n),`
     layout used in `models/marts/orders.sql` and `models/marts/customers.sql`?
   - **Aliases** - explicit `as` everywhere, no short table aliases, no re-aliased CTE names?
   - **Join style** - explicit join types, qualified column names when joining more than one
     table?
   - **What it's built on** - did Wizard build on top of existing marts (`orders`,
     `order_items`, `locations`), or did it re-join raw sources/staging models and re-derive
     logic (like food/drink classification) that already exists elsewhere?
   - **The food/drink revenue split specifically** - an order can contain both food and drink
     items. If the model computed the split from order-level totals rather than item-level
     detail, check whether `food_revenue + drink_revenue` could ever double-count an order's
     `total_revenue`.
   - **Materialization** - this mart grows by one row per location per day. Is it just a
     `table`, or did Wizard reach for something that handles that growth pattern (e.g.
     `incremental`)? If it went incremental, check the lookback filter specifically: does it
     handle the case where the target table is empty (its first-ever build)? A filter like
     `where order_date >= (select dateadd(day, -3, max(order_date)) from {{ this }})` returns
     `NULL` when `{{ this }}` is empty, which silently excludes every row instead of loading
     anything - a real, easy-to-miss bug, not just a style issue.
   - **YAML completeness** - model description, a description on every column, at least one
     model-level test, at least one unit test?

5. If you find violations, ask Wizard to fix them, or fix them yourself. Either way, you're
   about to turn these findings into something reusable - keep a running list.
