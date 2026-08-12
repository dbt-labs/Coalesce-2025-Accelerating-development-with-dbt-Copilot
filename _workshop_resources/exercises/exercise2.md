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

4. Now look closer, and compare the model against `dbt-styleguide.md` and against the
   project's other marts. Wizard infers standards from surrounding files, but there can be
   inconsistencies, and not everything that's written down actually gets followed. This is
   not an exhaustive list - Wizard's actual output will vary, so look for whatever doesn't
   match, not just the areas below:

   - **Naming, top to bottom** - compare every CTE name, column name, and any generated key
     against what's actually used elsewhere in this project's marts, not just what
     `dbt-styleguide.md` says. Does everything line up, or did something drift?
   - **Aliases and join style** - explicit `as` everywhere, no short table aliases, no
     re-aliased CTE names, explicit join types, qualified column names when joining more than
     one table?
   - **What it's built on** - did Wizard build on top of existing marts (`orders`,
     `order_items`, `locations`), or did it re-join raw sources/staging models and re-derive
     logic (like food/drink classification) that already exists elsewhere?
   - **What happens before the final grouping** - trace exactly what gets joined to what, and
     in what order, relative to when aggregation happens. Compare that structure to how the
     project's other marts are built, not just whether the numbers come out right.
   - **Every join's failure mode** - for each join in the model, ask what happens to a row on
     one side if there's no match on the other. Does that choice match how the rest of the
     project handles the same situation?
   - **The food/drink revenue split specifically** - an order can contain both food and drink
     items. Check whether the split could ever double-count an order's revenue.
   - **Materialization, and what would happen on a second run** - does this mart's
     materialization match how the project handles similar data elsewhere? If it's more
     sophisticated than a plain table, don't just confirm it builds once - think through (or
     actually run) what happens on a first build from nothing, and again right after that.
   - **Testing and documentation completeness** - model-level tests as well as column-level
     ones, and whether anything about how a total relates to its parts (timing, basis, what a
     number is actually built from) needed spelling out for someone reading this cold.
   - **Everything else every other mart in this project carries** - check this model's yml
     against a sibling mart's yml side by side. Anything configured consistently across the
     marts you already have that this new one is missing?

5. If you find violations, ask Wizard to fix them, or fix them yourself. Either way, you're
   about to turn these findings into something reusable - keep a running list.
