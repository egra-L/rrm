with

source as (

    select *

    from {{ source('raw', 'fred_usrecm') }}

),

lag_and_lead as (

    select
        observation_date,
        value,
        lag(value) over (order by observation_date) as prev_value,
        lead(value) over (order by observation_date) as next_value
    
    from source

)

select
    observation_date,
    value = 1 as is_recession,
    coalesce(value = 1 and prev_value = 0, false) as is_recession_peak,
    coalesce(value = 1 and next_value = 0, false) as is_recession_trough

from lag_and_lead