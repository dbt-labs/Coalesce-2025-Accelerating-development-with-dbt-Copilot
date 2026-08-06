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

    {% if is_incremental() %}
    where order_date >= (
        select coalesce(dateadd(day, -3, max(order_date)), '1900-01-01'::date)
        from {{ this }}
    )
    {% endif %}

),

order_items as (

    select * from {{ ref('order_items') }}

    {% if is_incremental() %}
    where order_date >= (
        select coalesce(dateadd(day, -3, max(order_date)), '1900-01-01'::date)
        from {{ this }}
    )
    {% endif %}

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
        ) as drink_revenue,
        sum(
            case
                when not is_food_item and not is_drink_item then product_price
                else 0
            end
        ) as other_revenue

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
        order_items_revenue.drink_revenue,
        order_items_revenue.other_revenue

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
        sum(drink_revenue) as drink_revenue,
        sum(other_revenue) as other_revenue

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
        daily_location_summary.drink_revenue,
        daily_location_summary.other_revenue

    from daily_location_summary

    left join locations
        on daily_location_summary.location_id = locations.location_id

)

select * from joined
