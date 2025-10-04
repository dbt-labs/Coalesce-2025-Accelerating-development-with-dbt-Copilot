with
    inventory as (

        select
            1 as item_id,
            'CorpTech' as company,
            'GadgetPro' as item_name,
            299.00 as price,
            '2025-07-10' as sale_date

        union all

        select
            2 as item_id,
            'TechCorp' as company,
            'WidgetMax' as item_name,
            199.00 as price,
            '2025-07-15' as sale_date

        union all

        select
            3 as item_id,
            'Innovatech' as company,
            'SmartHub' as item_name,
            499.00 as price,
            '2025-07-20' as sale_date

    )

select
    company,
    count(*) as items_sold,
    sum(price) as total_revenue, --revised to sum price field
    sum(price) / count(*) as avg_price

from inventory
where sale_date < date '2025-08-01' --revised to less than August 1st
group by company --added missing group by
