{% macro get_sources_from_registry() %}
    {% set relation_list = [
        source('raw', 'fred_t10y3m'),
        source('raw', 'fred_sahmrealtime'),
        source('raw', 'fred_icsa'),
        source('raw', 'fred_indpro'),
        source('raw', 'fred_permit')
    ] %}

    {{ return(relation_list) }}
{% endmacro %}