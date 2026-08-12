with

final as (

    select * from {{ ref('stg_supplies') }}

)

select * from final
