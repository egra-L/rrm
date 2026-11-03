{% macro transform_observation(transform_col, value_col, partition_col='obs.series_id', order_col='obs.month') %}
    case
        when lower(trim({{ transform_col }})) = 'level' then
            {{ value_col }}

        when lower(trim({{ transform_col }})) = 'yoy_pct' then
            100*((
                {{ value_col }}
                / nullif(
                    lag({{ value_col }}, 12) over (
                        partition by {{ partition_col }}
                        order by {{ order_col }}
                    ),
                    0
                )
            ) - 1)

        when lower(trim({{ transform_col }})) = 'pct_above_12m_min' then
            case
                when count({{ value_col }}) over (
                    partition by {{ partition_col }}
                    order by {{ order_col }}
                    rows between 11 preceding and current row
                ) = 12 then
                    100*((
                        {{ value_col }}
                        / nullif(
                            min({{ value_col }}) over (
                                partition by {{ partition_col }}
                                order by {{ order_col }}
                                rows between 11 preceding and current row
                            ),
                            0
                        )
                    ) - 1)
                else null
            end

        else null
    end
{% endmacro %}

