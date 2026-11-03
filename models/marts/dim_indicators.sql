with

registry as (

    select * from {{ ref('indicator_registry') }}

),

final as (

    select
        series_id,
        source,
        description,
        pillar,
        transform,
        threshold

    from registry

)

select * from final

