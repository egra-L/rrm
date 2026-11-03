with

usrecm as (

    select * from {{ ref('stg_fred__usrecm') }}

),

recession_months as (

    select
        observation_date as month,
        is_recession_peak,
        is_recession_trough,
        sum(
            case 
                when is_recession_peak then 1 
                else 0 
            end
        ) over (order by observation_date) as episode_id

    from usrecm
    where is_recession

),

episodes as (

    select
        episode_id,
        case
            when bool_or(is_recession_peak) then min(month)
        end as peak_month,
        case
            when bool_or(is_recession_trough) then max(month)
        end as trough_month,
        case
            when bool_or(is_recession_peak) and bool_or(is_recession_trough) then count(*)
        end as duration_months

    from recession_months
    group by episode_id
    having episode_id > 0

)

select * from episodes
order by episode_id