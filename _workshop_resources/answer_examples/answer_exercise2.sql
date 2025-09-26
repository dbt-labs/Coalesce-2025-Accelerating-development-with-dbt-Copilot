with joined as (
   select
       stg_order_items.*,
       stg_orders.order_date,
       stg_products.product_name,
       stg_products.product_price,
       stg_products.is_food_item,
       stg_products.is_drink_item,
       supplies.supply_cost,
       (supplies.supply_cost / stg_products.product_price) * 100 as supply_cost_percentage
   from
       {{ ref('stg_order_items') }}
   left join
       {{ ref('stg_orders') }}
   on
       stg_order_items.order_id = stg_orders.order_id
   left join
       {{ ref('stg_products') }}
   on
       stg_order_items.product_id = stg_products.product_id
   left join
       {{ ref('supplies') }}
   on
       stg_order_items.product_id = supplies.product_id
     )

  select * from joined
