with

fct as (

    select * from {{ ref('fct_indicators_monthly') }}

),

episodes as (

    select
        episode_id,
        peak_month,
        trough_month,
        duration_months,
        cast(peak_month - interval '24 months' as date) as window_start,
        cast(peak_month + interval '12 months' as date) as window_end

    from {{ ref('int_recession_episodes') }}

),

indicator_coverage as (

    select
        series_id,
        min(month) as first_scored_month

    from fct
    where score is not null
    group by series_id

),

indicator_episode_grid as (

    select
        c.series_id,
        e.episode_id,
        e.peak_month,
        e.trough_month,
        e.duration_months,
        e.window_start,
        e.window_end

    from indicator_coverage as c
    inner join episodes as e
        on c.first_scored_month <= e.window_start

),

final as (

    select
        g.series_id,
        g.episode_id,
        g.peak_month,
        g.trough_month,
        g.duration_months,
        g.window_start,
        g.window_end,
        coalesce(bool_or(f.is_red), false) as is_hit,
        min(case 
            when f.is_red then f.month 
        end) as first_red_month,
        date_diff(
            'month',
            min(case when f.is_red then f.month end),
            g.peak_month
        ) as lead_months

    from indicator_episode_grid as g
    left join fct as f
        on g.series_id = f.series_id
        and f.month between g.window_start and g.window_end
    group by
        g.series_id,
        g.episode_id,
        g.peak_month,
        g.trough_month,
        g.duration_months,
        g.window_start,
        g.window_end

)

select * from final
order by series_id, episode_id
