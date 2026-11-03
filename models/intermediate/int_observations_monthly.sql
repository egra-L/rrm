with 

observations as (

    select * from {{ ref('stg_fred__observations') }}

),

registry as (

    select * from {{ ref('indicator_registry') }}

),

series_monthly_range as (

    select
        obs.series_id,
        cast(date_trunc('month', min(obs.observation_date)) as date) as start_month,
        cast(date_trunc('month', max(obs.observation_date)) as date) as end_month
    
    from observations as obs
    group by obs.series_id

),

series_spine as (

    select
        smr.series_id,
        cast(
            unnest(
                generate_series(
                    smr.start_month, 
                    smr.end_month, 
                    interval '1 month'
                )
            ) as date
        ) as month
    
    from series_monthly_range as smr

),

observations_aggregated as (

    select
        obs.series_id,
        cast(date_trunc('month', obs.observation_date) as date) as month,
        case
            when lower(trim(reg.aggregation)) = 'avg' then avg(obs.value)
            when lower(trim(reg.aggregation)) = 'none' then any_value(obs.value)
            else avg(obs.value)
        end as value
    
    from observations as obs
    inner join registry as reg
        on obs.series_id = reg.series_id
    group by
        obs.series_id,
        cast(date_trunc('month', obs.observation_date) as date),
        reg.aggregation

),

final as (

    select
        spine.series_id,
        spine.month,
        agg.value
    
    from series_spine as spine
    left join observations_aggregated as agg
        on spine.series_id = agg.series_id
        and spine.month = agg.month

)

select * from final

