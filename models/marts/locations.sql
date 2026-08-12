with

final as (

    select * from {{ ref('stg_locations') }}

)

select * from final
