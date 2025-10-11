{# Simple macro #}
{% macro determine_status(date_column) %}
     case
         when {{ date_column }} >= dateadd(year, -1, current_date()) then 'active'
         else 'inactive'
     end
{% endmacro %}


{# Complex macro #}
{% macro select_customer_columns(model_name) %}
    {# Get the list of columns from the model #}
    {% set columns = adapter.get_columns_in_relation(ref(model_name)) %}

    {# Filter columns to find those containing 'customer' (case-insensitive) #}
    {% set customer_columns = [] %}
    {% for column in columns %}
        {% if 'customer' in column.name | lower %}
            {% do customer_columns.append(column.name) %}
        {% endif %}
    {% endfor %}

    {# Construct the SQL statement #}
    with customer_columns as (
        {% if customer_columns | length > 0 %}
            select {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        {% else %}
            select null as col
        {% endif %}
    )

    select * from customer_columns
{% endmacro %}
