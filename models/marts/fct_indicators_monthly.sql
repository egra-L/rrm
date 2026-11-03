with

recession_flag as (

    select * from {{ ref('stg_fred__usrecm') }}

),

transformed as (

    select * from {{ ref('int_indicators_transformed') }}

),

scored as (

    select * from {{ ref('int_indicators_scored') }}

),

final as (

    select
        t.series_id,
        t.month,
        t.value,
        t.transformed_value,
        s.score,
        s.is_red,
        rf.is_recession

    from transformed as t
    inner join scored as s
        on t.series_id = s.series_id
        and t.month = s.month
    left join recession_flag as rf
        on t.month = rf.observation_date
    where rf.is_recession  is not null   -- drop any observations past the last non-NULL value in is_recession

)

select * from final