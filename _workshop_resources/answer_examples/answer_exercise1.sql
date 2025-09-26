with customers as (
   select * from {{ ref('stg_customers') }}
),
orders as (
   select * from {{ ref('orders') }}
),
order_items as (
   select * from {{ ref('order_items') }}
),
order_summary as (
   select
       o.customer_id,
       count(distinct o.order_id) as lifetime_orders,
       min(o.order_date) as first_order_date,
       max(o.order_date) as last_order_date,
       sum(oi.product_price) as lifetime_spend_pretax,
       sum(o.order_total) as lifetime_spend
   from orders o
   inner join order_items oi on o.order_id = oi.order_id
   group by o.customer_id
),
final as (
   select
       c.customer_id,
       c.customer_name,
       os.lifetime_orders,
       os.first_order_date,
       os.last_order_date,
       os.lifetime_spend_pretax,
       os.lifetime_spend,
       case
           when datediff(year, os.last_order_date, current_date) < 1 then 'current'
           else 'inactive'
       end as customer_status
   from order_summary os
   inner join customers c on os.customer_id = c.customer_id
)
select *
from final
