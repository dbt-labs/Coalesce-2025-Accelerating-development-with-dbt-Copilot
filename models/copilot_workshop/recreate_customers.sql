with 
    customers as (
        select * from {{ ref('stg_customers') }}
    ),
    orders as (
        select * from {{ ref('orders') }}
    ),
    order_items as (
        select * from {{ ref('order_items') }}
    )
select 
    *
from 
    customers
join 
    orders on customers.customer_id = orders.customer_id
join 
    order_items on orders.order_id = order_items.order_id;


with 
    customers as (
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
            orders.customer_id,
            count(distinct orders.order_id) as lifetime_orders,
            min(orders.order_date) as first_order_date,
            max(orders.order_date) as last_order_date,
            sum(order_items.product_price) as lifetime_spend_pretax,
            sum(orders.order_total) as lifetime_spend
        from 
            orders
        join 
            order_items on orders.order_id = order_items.order_id
        group by 
            orders.customer_id
    )
select 
    *
from 
    customers
join 
    orders on customers.customer_id = orders.customer_id
join 
    order_items on orders.order_id = order_items.order_id;

with 
    customers as (
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
            orders.customer_id,
            count(distinct orders.order_id) as lifetime_orders,
            min(orders.order_date) as first_order_date,
            max(orders.order_date) as last_order_date,
            sum(order_items.product_price) as lifetime_spend_pretax,
            sum(orders.order_total) as lifetime_spend
        from 
            orders
        join 
            order_items on orders.order_id = order_items.order_id
        group by 
            orders.customer_id
    ),
    final as (
        select 
            customers.customer_id,
            customers.customer_name,  -- Assuming customer_name exists
            order_summary.lifetime_orders,
            order_summary.first_order_date,
            order_summary.last_order_date,
            order_summary.lifetime_spend_pretax,
            order_summary.lifetime_spend,
            case 
                when order_summary.last_order_date >= dateadd(year, -1, current_date) then 'current'
                else 'inactive'
            end as customer_status
        from 
            customers
        join 
            order_summary on customers.customer_id = order_summary.customer_id
    )
select 
    *
from 
    final;