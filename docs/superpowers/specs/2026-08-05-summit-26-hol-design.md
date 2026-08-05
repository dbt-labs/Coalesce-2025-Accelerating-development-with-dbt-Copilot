# Summit 2026 Hands-On Lab: Accelerating Analytics with AI — Design

## Context

This repo currently supports "Accelerating Development with dbt Copilot," a Coalesce 2025
hands-on lab built around five independent, unrelated exercises (SQL prompting, doc/test/
semantic-model generation, macro generation, SQL troubleshooting, macro troubleshooting)
run against a jaffle_shop dbt project.

The new session, "Accelerating Analytics with AI" (dbt Summit 2026, per the course outline
at `docs.google.com/document/d/1aUm-_ro3PsCAvaX4TnvGvselpnP8D0IiDtzV8fCS3Vg` and slide draft
at `docs.google.com/presentation/d/1YLv_K6PD7vT5tDwAQVQ0nM1pm7Xh13H_4FGsMp6n3Aw`), is a single
continuous narrative about **dbt Wizard** in **dbt Studio**: build a mart model, review it
against project conventions, capture those conventions so Wizard follows them automatically
(AGENTS.md + a custom skill), then rebuild and watch the standards pay off. The slides call
this the "prompt → review → capture → accelerate" loop, broken into five "Practical blocks"
that map 1:1 to five lessons in the course outline.

This repo is being rebuilt on a new branch, `summit-26-hol`, as the **fully-built end state**
of the lab — every artifact attendees would create during the session (AGENTS.md, the skill,
both new mart models) is committed in its real project location. The user will later create a
separate, trimmed starter branch (removing those attendee-created artifacts) to hand to
workshop attendees. That trimming step is out of scope for this work.

## Non-goals

- No changes to the slide deck or course outline docs themselves.
- No creation of the trimmed "starter" branch — the user does this manually afterward.
- No changes to the underlying jaffle_shop staging models, `customers`/`orders`/`order_items`/
  `products`/`locations`/`supplies` marts, `dbt-styleguide.md`, `packages.yml`, or
  `dbt_project.yml`. These remain the foundation the new marts are built on.

## Repo structure changes

### Delete (old Copilot-era content with no place in the new narrative)

- `models/copilot_workshop/` (`recreate_customers.sql`, `source_to_target_example.sql`,
  `metricflow_time_spine.sql`, `metricflow_time_spine.yml`)
- `macros/activity_status.sql`
- `macros/complex_nested_logic.sql`
- `macros/customer_fields_cte.sql`
- `analyses/troubleshooting_macro.sql`
- `analyses/troubleshooting_sql.sql`
- `_workshop_resources/answer_examples/` (entire folder — redundant now that finished
  artifacts live in their real locations)

### Keep unchanged

- `models/staging/*`
- `models/marts/customers.sql|.yml`, `orders.sql|.yml`, `order_items.sql|.yml`,
  `products.sql`, `locations.sql`, `supplies.sql`
- `macros/cents_to_dollars.sql`
- `dbt-styleguide.md`, `packages.yml`, `dbt_project.yml`

### Add

- `AGENTS.md` (project root)
- `.agents/skills/create-mart-model/SKILL.md`
- `models/marts/location_performance.sql` + `.yml`
- `models/marts/product_performance.sql` + `.yml`
- Rewritten `README.md`
- Rewritten `_workshop_resources/exercises/exercise1.md` through `exercise5.md`

Skill path note: the slide deck's screenshot of the recommended skill structure shows
`.agents/skills/NAME/SKILL.md`, not `.claude/skills/`. The user confirmed both work in dbt
platform but `.agents/` is preferred for LLM-vendor neutrality — use `.agents/skills/`.

## The new mart models

Both new marts follow the same pattern established by the existing marts: plain `with`
CTEs, snake_case, explicit joins, aggregation before joining where possible, group-by-number,
descriptions + `data_tests` + `unit_tests` in the yml matching the thoroughness of
`orders.yml`/`customers.yml`.

### `location_performance`

Business ask (used verbatim as the Exercise 1 prompt): daily revenue, order count, and
food-vs-drink revenue split, per location.

Key design decision: compute the food/drink revenue split from `order_items` (item-level
`product_price`, `is_food_item`, `is_drink_item`) rather than from `orders`' order-level
`is_food_order`/`is_drink_order` booleans. An order can contain both food and drink items, so
summing whole `order_total` into both buckets would double-count revenue. Aggregating at the
item level first, then joining up to `orders` (for `location_id`/`order_date`) and `locations`
(for `location_name`) — both many-to-one joins — avoids fan-out and produces a `food_revenue +
drink_revenue = total_revenue` identity that can be asserted as a test. This double-counting
trap is also the naive mistake Wizard's first pass is expected to make, giving Exercise 2 a
concrete, verifiable defect to catch (not just a style nitpick).

Materialized incrementally (grain: `location_id` + `order_date`, `merge` strategy, 3-day
lookback on `order_date`) since it's a daily-grain aggregate that only grows forward. This is
a new standard not yet in `dbt-styleguide.md` — captured in `AGENTS.md` during Exercise 3.

```sql
-- models/marts/location_performance.sql
{{
    config(
        materialized='incremental',
        unique_key=['location_id', 'order_date'],
        incremental_strategy='merge'
    )
}}

with

order_items as (

    select * from {{ ref('order_items') }}

    {% if is_incremental() %}
    where order_date >= (select dateadd(day, -3, max(order_date)) from {{ this }})
    {% endif %}

),

orders as (

    select * from {{ ref('orders') }}

),

locations as (

    select * from {{ ref('locations') }}

),

order_items_revenue as (

    select
        order_id,

        sum(product_price) as total_revenue,
        sum(
            case
                when is_food_item then product_price
                else 0
            end
        ) as food_revenue,
        sum(
            case
                when is_drink_item then product_price
                else 0
            end
        ) as drink_revenue

    from order_items

    group by 1

),

orders_with_revenue as (

    select
        orders.order_id,
        orders.location_id,
        orders.order_date,

        order_items_revenue.total_revenue,
        order_items_revenue.food_revenue,
        order_items_revenue.drink_revenue

    from orders

    left join order_items_revenue
        on orders.order_id = order_items_revenue.order_id

),

daily_location_summary as (

    select
        location_id,
        order_date,

        count(distinct order_id) as count_orders,
        sum(total_revenue) as total_revenue,
        sum(food_revenue) as food_revenue,
        sum(drink_revenue) as drink_revenue

    from orders_with_revenue

    group by 1, 2

),

joined as (

    select
        daily_location_summary.location_id,
        locations.location_name,
        daily_location_summary.order_date,

        daily_location_summary.count_orders,
        daily_location_summary.total_revenue,
        daily_location_summary.food_revenue,
        daily_location_summary.drink_revenue

    from daily_location_summary

    left join locations
        on daily_location_summary.location_id = locations.location_id

)

select * from joined
```

```yaml
# models/marts/location_performance.yml
models:
  - name: location_performance
    description: Daily performance summary per location, offering total revenue, order count, and a food vs. drink revenue split. One row per location per day.
    data_tests:
      - dbt_utils.expression_is_true:
          expression: "food_revenue + drink_revenue = total_revenue"
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - location_id
            - order_date
    columns:
      - name: location_id
        description: The foreign key relating to the location this summary row is for.
        data_tests:
          - not_null
          - relationships:
              to: ref('locations')
              field: location_id
      - name: location_name
        description: The name of the location.
      - name: order_date
        description: The date this summary row represents.
        data_tests:
          - not_null
      - name: count_orders
        description: The number of orders placed at this location on this date.
      - name: total_revenue
        description: The sum of all order revenue (pre-tax, pre-supply-cost) at this location on this date.
      - name: food_revenue
        description: The portion of total_revenue attributable to food items.
      - name: drink_revenue
        description: The portion of total_revenue attributable to drink items.

unit_tests:
  - name: test_food_and_drink_revenue_split_correctly
    description: "Test that item-level revenue is split into food/drink buckets without double-counting an order that contains both."
    model: location_performance
    given:
      - input: ref('order_items')
        rows:
          - { order_id: 1, order_item_id: 1, product_price: 5.00, is_food_item: true, is_drink_item: false }
          - { order_id: 1, order_item_id: 2, product_price: 3.00, is_food_item: false, is_drink_item: true }
      - input: ref('orders')
        rows:
          - { order_id: 1, location_id: 1, order_date: "2026-01-01" }
      - input: ref('locations')
        rows:
          - { location_id: 1, location_name: "Vice City" }
    expect:
      rows:
        - {
            location_id: 1,
            location_name: "Vice City",
            order_date: "2026-01-01",
            count_orders: 1,
            total_revenue: 8.00,
            food_revenue: 5.00,
            drink_revenue: 3.00,
          }
```

### `product_performance`

Business ask (used verbatim as the Exercise 5 prompt): daily revenue, order count, and
margin (item price minus supply cost) per product — a different business question that
exercises the same `create-mart-model` skill and `AGENTS.md` conventions captured in
Exercise 3, to demonstrate the pattern generalizes.

```sql
-- models/marts/product_performance.sql
{{
    config(
        materialized='incremental',
        unique_key=['product_id', 'order_date'],
        incremental_strategy='merge'
    )
}}

with

order_items as (

    select * from {{ ref('order_items') }}

    {% if is_incremental() %}
    where order_date >= (select dateadd(day, -3, max(order_date)) from {{ this }})
    {% endif %}

),

products as (

    select * from {{ ref('products') }}

),

daily_product_summary as (

    select
        product_id,
        order_date,

        count(distinct order_id) as count_orders,
        count(order_item_id) as count_items_sold,
        sum(product_price) as total_revenue,
        sum(supply_cost) as total_supply_cost,
        sum(product_price) - sum(supply_cost) as total_margin

    from order_items

    group by 1, 2

),

joined as (

    select
        daily_product_summary.product_id,
        products.product_name,
        daily_product_summary.order_date,

        daily_product_summary.count_orders,
        daily_product_summary.count_items_sold,
        daily_product_summary.total_revenue,
        daily_product_summary.total_supply_cost,
        daily_product_summary.total_margin

    from daily_product_summary

    left join products
        on daily_product_summary.product_id = products.product_id

)

select * from joined
```

```yaml
# models/marts/product_performance.yml
models:
  - name: product_performance
    description: Daily performance summary per product, offering revenue, items sold, and margin (item price minus supply cost). One row per product per day.
    data_tests:
      - dbt_utils.expression_is_true:
          expression: "total_revenue - total_supply_cost = total_margin"
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - product_id
            - order_date
    columns:
      - name: product_id
        description: The foreign key relating to the product this summary row is for.
        data_tests:
          - not_null
          - relationships:
              to: ref('products')
              field: product_id
      - name: product_name
        description: The name of the product.
      - name: order_date
        description: The date this summary row represents.
        data_tests:
          - not_null
      - name: count_orders
        description: The number of distinct orders that included this product on this date.
      - name: count_items_sold
        description: The number of units of this product sold on this date.
      - name: total_revenue
        description: The sum of item-level revenue for this product on this date.
      - name: total_supply_cost
        description: The sum of supply cost for this product on this date.
      - name: total_margin
        description: total_revenue minus total_supply_cost.

unit_tests:
  - name: test_margin_computes_correctly
    description: "Test that margin is revenue minus supply cost."
    model: product_performance
    given:
      - input: ref('order_items')
        rows:
          - { order_id: 1, order_item_id: 1, product_id: 1, order_date: "2026-01-01", product_price: 5.00, supply_cost: 2.00 }
          - { order_id: 2, order_item_id: 2, product_id: 1, order_date: "2026-01-01", product_price: 5.00, supply_cost: 2.00 }
      - input: ref('products')
        rows:
          - { product_id: 1, product_name: "Nutellaphone" }
    expect:
      rows:
        - {
            product_id: 1,
            product_name: "Nutellaphone",
            order_date: "2026-01-01",
            count_orders: 2,
            count_items_sold: 2,
            total_revenue: 10.00,
            total_supply_cost: 4.00,
            total_margin: 6.00,
          }
```

## AGENTS.md (project root)

Concise — points to the existing styleguide for general conventions rather than duplicating
it, and adds the two new project-specific patterns this lab's exercises surface.

```markdown
# AGENTS.md

## SQL style and naming conventions

Follow `dbt-styleguide.md` for all naming, SQL styling, Jinja styling, and YAML styling
conventions in this project. Every new model must conform to it.

## Building new marts

- Before joining raw sources, check whether an existing mart or staging model already
  contains the logic you need (e.g. food/drink classification, revenue totals, customer
  lifetime metrics). Build on top of existing marts rather than re-deriving that logic from
  raw sources — it keeps business logic defined in one place and avoids accidental
  join fan-out.
- When you do need item-level detail (for example, splitting revenue by category), aggregate
  at the most granular level first, then join the aggregate up to the coarser grain. Don't
  join first and then aggregate — it's easy to double-count when a parent record (like an
  order) can match multiple categories.
- Mart models with a daily or event grain that only grows forward over time (e.g. one row per
  location per day) should be materialized as `incremental`, with a `unique_key` matching the
  grain and a short lookback window (2-3 days) on the date column, using the `merge`
  incremental strategy. Marts with a fixed, non-growing grain (like one row per customer or
  per product) stay `table`-materialized per `dbt_project.yml` defaults.
- Every new mart needs a `.yml` with a model description, a column description for every
  column, at least one `data_tests` assertion on the model as a whole (e.g. a reconciling
  expression or a uniqueness-of-grain check), and at least one `unit_tests` case, matching the
  thoroughness of `models/marts/orders.yml` and `models/marts/customers.yml`.

## Reusable patterns

See `.agents/skills/create-mart-model/SKILL.md` for the step-by-step pattern to follow when
building a new mart model.
```

## `.agents/skills/create-mart-model/SKILL.md`

```markdown
---
name: create-mart-model
description: Use when building a new dbt mart model in this project - covers grain selection, building on existing marts, incremental materialization, and required tests/docs.
---

# Creating a mart model

1. **Identify the grain.** State explicitly what one row represents (e.g. "one row per
   location per day"). Name the model to describe what it is, not how it's built (e.g.
   `location_performance`, not `location_orders_joined`).

2. **Reuse existing marts before touching raw sources.** Check `models/marts/` and
   `models/staging/` for a model that already contains the metric or classification logic you
   need. Join to that mart rather than re-deriving the same logic. This keeps business logic
   defined once and avoids duplicating (and potentially diverging from) an existing
   definition.

3. **Aggregate before you join.** If a metric needs item-level detail (for example, splitting
   revenue by a category that varies per item within a parent record), aggregate at the
   detail grain first, then join the pre-aggregated result up to the coarser grain. Joining
   before aggregating risks fan-out and double-counted parent-level values.

4. **Choose materialization by grain behavior.** If the new mart's grain grows forward over
   time (a new row appears each day/event and old rows don't change), materialize it as
   `incremental` with:
   - `unique_key` set to the grain's columns
   - `incremental_strategy='merge'`
   - an `is_incremental()` filter with a short lookback window (2-3 days) on the date column,
     to catch any late-arriving or corrected records

   If the grain is fixed (one row per a dimension that doesn't grow, like one row per
   customer or product), leave it `table`-materialized (the project default for marts).

5. **Write the SQL to match project style.** Follow `dbt-styleguide.md`: `with` CTEs, explicit
   `as` aliases, snake_case, explicit join types, group-by-number, no short table aliases.

6. **Write the YAML.** Every model needs:
   - a model-level `description`
   - a `description` for every column
   - at least one model-level `data_tests` entry that reconciles the model's own numbers
     (e.g. component columns summing to a total) or asserts the grain is unique
     (`dbt_utils.unique_combination_of_columns`)
   - at least one `unit_tests` case with representative input/output rows

7. **Validate.** Run `dbt build --select <model_name>` and confirm it compiles, runs, and
   passes its tests before considering the model done.
```

## Exercises (`_workshop_resources/exercises/`)

Five files, each mapping to one "Practical block" from the slides / one lesson from the
course outline. Content is written as attendee-facing instructions (these files are
identical between this branch and the eventual trimmed starter branch — only the
attendee-created artifacts differ between branches).

- **`exercise1.md` — Build the mart.** Prompt Wizard, in the business language given above,
  to build `location_performance` with tests and docs. Emphasizes iterating with intent
  (reviewing Wizard's plan/output and asking follow-up questions) rather than accepting the
  first draft outright.
- **`exercise2.md` — Review the changes.** Use Wizard to preview the resulting data and view
  lineage. Then manually check the model against `dbt-styleguide.md`: CTE structure/naming,
  explicit aliases, join style, whether it built on existing marts or re-joined raw sources,
  whether the food/drink split double-counts, materialization, and yml completeness. Lists
  concrete things to look for without spelling out exactly what's wrong (attendees should
  find the divergences themselves, since Wizard's actual output will vary session to
  session).
- **`exercise3.md` — Capture your standards.** Part 1: write `AGENTS.md`. Part 2: write the
  `create-mart-model` skill. Points to the two new patterns discovered in Exercise 2
  (build-on-marts, aggregate-before-join, incremental-for-growing-grain) as the things worth
  capturing.
- **`exercise4.md` — See the payoff, round 1.** Delete `location_performance.sql`/`.yml`,
  start a new Wizard session, re-run the Exercise 1 prompt verbatim, compare against the
  Exercise 2 checklist.
- **`exercise5.md` — Do the loop again.** New business ask (`product_performance`, given
  above), full prompt → review → capture(if needed) → done cycle, framed as proof the
  captured standards generalize to a new task.

## README.md

Rewritten to describe the new session: title "Accelerating Analytics with AI," a short
overview matching the course outline's course overview paragraph, dbt Studio setup
pointer, and a pointer to `_workshop_resources/exercises/` for the lab steps. Uses "dbt
platform" (lowercase p) rather than "dbt Cloud," and capitalizes "dbt Studio"/"dbt Wizard" as
product proper nouns, per brand conventions.

## Testing / validation

Local `dbt parse`/`dbt compile` cannot be run without a warehouse connection in this
environment (no `profiles.yml` credentials configured here). The user will validate by
running `dbt build` against the actual dbt Studio sandbox after these changes land. As a
substitute, this design was checked for internal consistency by hand: column names traced
across every CTE, join keys confirmed to exist on both sides (`location_id` on `orders` via
`stg_orders.store_id`, `product_id`/`supply_cost` on `order_items` via its existing
`order_supplies_summary` join), and the food/drink revenue identity confirmed to hold by
construction (see note below).

## Note on the revenue-split identity

`is_food_item` and `is_drink_item` (in `stg_products.sql`) are both derived from the single
`type` column (`type = 'jaffle'` and `type = 'beverage'` respectively), so a product can be at
most one of the two — they can't both be true for the same row. A product whose `type` is
neither (e.g. merchandise) has both flags false and contributes to `total_revenue` without
landing in `food_revenue` or `drink_revenue`. That's expected: the `food_revenue +
drink_revenue = total_revenue` test only needs "every food/drink dollar lands in exactly one
bucket," not "every product is food or drink," and it holds under the current source data.
