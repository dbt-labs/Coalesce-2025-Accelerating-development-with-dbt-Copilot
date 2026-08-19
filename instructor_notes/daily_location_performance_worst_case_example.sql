-- INSTRUCTOR EXAMPLE ONLY - deliberately violates every standard in AGENTS.md/SKILL.md.
-- See instructor_notes/ for the annotated version and explanation.
-- Do not use as a template, and do not ship this file to attendees.

{{
    config(
        materialized='incremental',
        unique_key=['location_id', 'order_date'],
        incremental_strategy='merge'
    )
}}

with

orders as (

    select * from {{ ref('orders') }}

    -- VIOLATION: incremental filter applied to only one of the two driving CTEs
    -- (order_items below is left completely unfiltered), and with no coalesce() safety
    -- net - on an empty target relation, max(order_date) is NULL, this where clause
    -- silently excludes every row, and the model never loads anything.
    {% if is_incremental() %}
    where order_date >= (select dateadd(day, -3, max(order_date)) from {{ this }})
    {% endif %}

),

order_items as (

    -- VIOLATION: raw, un-aggregated order_items - never pre-aggregated to its own grain
    -- before being joined into the final grouping step below.
    select * from {{ ref('order_items') }}

),

locations as (

    select * from {{ ref('locations') }}

),

-- VIOLATION: terminal CTE named after the model itself, instead of `final`.
daily_location_performance_worst_case_example as (

    select
        -- VIOLATION: surrogate key named ..._id instead of ..._key
        {{ dbt_utils.generate_surrogate_key(['orders.location_id', 'orders.order_date']) }}
            as daily_location_performance_worst_case_example_id,
        orders.location_id,
        locations.location_name,
        orders.order_date,

        -- VIOLATION: order_count instead of count_orders
        count(distinct orders.order_id) as order_count,

        -- VIOLATION (real bug, not just style): orders is joined directly to the
        -- un-aggregated order_items CTE, so a multi-item order's order_total is
        -- repeated once per item and gets summed multiple times here - this actually
        -- inflates total_revenue, it's not just a style deviation. It's also on a
        -- different basis than food/drink revenue below (tax-inclusive order_total vs.
        -- pre-tax item prices) with that mismatch left undocumented.
        sum(orders.order_total) as total_revenue,
        sum(
            case
                when order_items.is_food_item then order_items.product_price
                else 0
            end
        ) as food_revenue,
        sum(
            case
                when order_items.is_drink_item then order_items.product_price
                else 0
            end
        ) as drink_revenue

    from orders

    -- VIOLATION: raw order_items joined directly into the same step that does the
    -- final grouping, instead of being pre-aggregated to order-grain first.
    inner join order_items on orders.order_id = order_items.order_id

    -- VIOLATION: inner join to a dimension table (locations) instead of left join -
    -- would silently drop any order whose location_id has no match.
    inner join locations on orders.location_id = locations.location_id

    group by 1, 2, 3, 4

)

select * from daily_location_performance_worst_case_example
