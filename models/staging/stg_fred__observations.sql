with 

unioned as (

    {{ dbt_utils.union_relations(
        relations = get_sources_from_registry(),
        column_override = {"value": "varchar"}
    ) }}

),

transformed as (

    select
        series_id,
        observation_date,
        try_cast(value as double) as value
    
    from unioned
    
)

select * from transformed
