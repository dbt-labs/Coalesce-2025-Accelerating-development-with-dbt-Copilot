with

source as (
    
    select * from {{ source('ecom', 'raw_customers') }}

),

final as (

    select

        ----------  ids
        id as customer_id,

        ---------- text
        name as customer_name

    from source

)

select * from final
