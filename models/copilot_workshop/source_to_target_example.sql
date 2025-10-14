with order_items as (
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
        sum(supply_cost) as supply_cost
    from supplies
    group by product_id
),

joined as (
    select 
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        o.order_date,
        p.product_name,
        p.product_price,
        p.is_food_item,
        p.is_drink_item,
        oss.supply_cost,
        (oss.supply_cost / p.product_price) * 100 as supply_cost_percentage
    from order_items oi
    left join orders o on oi.order_id = o.order_id
    left join products p on oi.product_id = p.product_id
    left join order_supplies_summary oss on oi.product_id = oss.product_id
)

select *
from joined;