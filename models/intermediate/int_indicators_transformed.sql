with 

observations_monthly as (

    select * from {{ ref('int_observations_monthly') }}

),

registry as (

    select * from {{ ref('indicator_registry') }}

),

transformed as (

    select
        obs.series_id,
        obs.month,
        obs.value,
        {{ transform_observation(
            transform_col='reg.transform',
            value_col='obs.value',
            partition_col='obs.series_id',
            order_col='obs.month'
        ) }} as transformed_value

    from observations_monthly as obs
    inner join registry as reg
        on obs.series_id = reg.series_id

)

select * from transformed