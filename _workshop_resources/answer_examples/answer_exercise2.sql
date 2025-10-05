with order_items as (
    select 
        order_item_id,
        order_id,
        product_id
    from {{ ref('stg_order_items') }}
),

orders as (
    select 
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        orders.order_date
    from order_items
    inner join {{ ref('stg_orders') }} as orders
        on order_items.order_id = orders.order_id
),

products as (
    select 
        orders.order_item_id,
        orders.order_id,
        orders.product_id,
        orders.order_date,
        products.product_name,
        products.product_price,
        products.is_food_item,
        products.is_drink_item
    from orders
    inner join {{ ref('stg_products') }} as products
        on orders.product_id = products.product_id
),

order_supplies_summary as (
    select 
        product_id,
        sum(supply_cost) as supply_cost
    from {{ ref('stg_supplies') }}
    group by product_id
)

select 
    products.order_item_id,
    products.order_id,
    products.product_id,
    products.order_date,
    products.product_name,
    products.product_price,
    products.is_food_item,
    products.is_drink_item,
    order_supplies_summary.supply_cost,
    (order_supplies_summary.supply_cost / products.product_price) * 100 as supply_cost_percentage
from products
left join order_supplies_summary
    on products.product_id = order_supplies_summary.product_id