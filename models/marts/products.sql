with

final as (

    select * from {{ ref('stg_products') }}

)

select * from final
