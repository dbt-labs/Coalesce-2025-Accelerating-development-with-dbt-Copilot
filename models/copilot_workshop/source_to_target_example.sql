with order_items as (
    select 
        order_item_id,
        order_id,
        product_id
    from {{ ref('stg_order_items') }}
),

orders as (
    select 
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        o.order_date
    from order_items oi
    inner join {{ ref('stg_orders') }} o
        on oi.order_id = o.order_id
),

products as (
    select 
        o.order_item_id,
        o.order_id,
        o.product_id,
        o.order_date,
        p.product_name,
        p.product_price,
        p.is_food_item,
        p.is_drink_item
    from orders o
    inner join {{ ref('stg_products') }} p
        on o.product_id = p.product_id
),

order_supplies_summary as (
    select 
        product_id,
        sum(supply_cost) as supply_cost
    from {{ ref('stg_supplies') }}
    group by product_id
),

joined as (
    select 
        p.order_item_id,
        p.order_id,
        p.product_id,
        p.order_date,
        p.product_name,
        p.product_price,
        p.is_food_item,
        p.is_drink_item,
        oss.supply_cost,
        case 
            when p.product_price > 0 then (oss.supply_cost / p.product_price) * 100
            else null
        end as supply_cost_percentage
    from products p
    left join order_supplies_summary oss
        on p.product_id = oss.product_id
)

select *
from joined