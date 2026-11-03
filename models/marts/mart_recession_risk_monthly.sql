with

fct as (

    select * from {{ ref('fct_indicators_monthly') }}

),

dim as (

    select * from {{ ref('dim_indicators') }}

),

weights as (

    select * from {{ ref('pillar_weights') }}

),

monthly_indicators as (

    select
        month,
        {{ dbt_utils.pivot(
            column='series_id',
            values=dbt_utils.get_column_values(ref('dim_indicators'), 'series_id'),
            agg='max',
            then_value='score',
            else_value='null',
            prefix='score_',
            quote_identifiers=false
        ) }},
        count(score) as n_indicators_scored,
        count(*) filter (where is_red) as n_red,
        bool_or(is_recession) as is_recession

    from fct
    group by month

),

pillar_monthly as (

    select
        f.month,
        d.pillar,
        avg(f.score) as pillar_score

    from fct as f
    inner join dim as d
        on f.series_id = d.series_id
    where f.score is not null
    group by
        f.month,
        d.pillar

),

composite_monthly as (

    select
        pm.month,
        sum(pm.pillar_score * w.weight) / nullif(sum(w.weight), 0) as composite_score

    from pillar_monthly as pm
    inner join weights as w
        on pm.pillar = w.pillar
    group by pm.month

),

final as (

    select
        mi.month,
        cm.composite_score,
        mi.n_indicators_scored,
        mi.n_red,
        mi.is_recession,
        mi.score_t10y3m,
        mi.score_sahmrealtime,
        mi.score_icsa,
        mi.score_indpro,
        mi.score_permit

    from monthly_indicators as mi
    left join composite_monthly as cm
        on mi.month = cm.month

)

select * from final
order by month