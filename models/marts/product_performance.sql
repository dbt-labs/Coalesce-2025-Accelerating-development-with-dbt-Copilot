{{
    config(
        materialized='incremental',
        unique_key='product_performance_key',
        incremental_strategy='merge'
    )
}}

with

order_items as (

    select * from {{ ref('order_items') }}

    {% if is_incremental() %}
    where order_date >= (
        select coalesce(dateadd(day, -3, max(order_date)), '1900-01-01'::date)
        from {{ this }}
    )
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

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['daily_product_summary.product_id', 'daily_product_summary.order_date']) }}
            as product_performance_key,
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

select * from final
