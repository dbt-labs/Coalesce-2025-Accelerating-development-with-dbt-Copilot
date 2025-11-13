with 
    order_items as (
        select 
            order_item_id,
            order_id,
            product_id
        from {{ ref('stg_order_items') }}
    ),
    orders as (
        select 
            order_id,
            order_date
        from {{ ref('stg_orders') }}
    ),
    products as (
        select 
            product_id,
            product_name,
            product_price,
            is_food_item,
            is_drink_item
        from {{ ref('stg_products') }}
    ),
    order_supplies_summary as (
        select 
            product_id,
            sum(supply_cost) as total_supply_cost
        from {{ ref('stg_supplies') }}
        group by product_id
    )

select 
    order_items.order_item_id,
    order_items.order_id,
    order_items.product_id,
    orders.order_date,
    products.product_name,
    products.product_price,
    products.is_food_item,
    products.is_drink_item,
    order_supplies_summary.total_supply_cost,
    (order_supplies_summary.total_supply_cost / products.product_price) * 100 as supply_cost_percentage
from order_items
left join orders on order_items.order_id = orders.order_id
left join products on order_items.product_id = products.product_id
left join order_supplies_summary on order_items.product_id = order_supplies_summary.product_id