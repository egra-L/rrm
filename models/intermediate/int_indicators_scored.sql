with

transformed as (
    
    select * from {{ ref('int_indicators_transformed') }}

),

registry as (

    select * from {{ ref('indicator_registry') }}

),

scored as (

    select
        t.series_id,
        t.month,
        t.transformed_value,
        case
            when t.transformed_value is not null then
                100.0 * least(
                    greatest(
                        (t.transformed_value - reg.safe_level) / (reg.threshold - reg.safe_level),
                        0
                    ),
                    1
                )
        end as score

    from transformed as t
    inner join registry as reg
        on t.series_id = reg.series_id

),

final as (

    select
        s.series_id,
        s.month,
        s.score,
        s.score >= 100 as is_red

    from scored as s

)

select * from final