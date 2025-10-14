{% macro select_customer_columns(model_name) %}
    {# Retrieve all columns from the specified model #}
    {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
    {%- set customer_columns = [] -%}
    
    {# Iterate over each column to check if 'customer' is in the column name (case-insensitive) #}
    {%- for column in columns -%}
        {%- if 'customer' in column.name | lower -%}
            {# Append column name to the list if it contains 'customer' #}
            {%- do customer_columns.append(column.name) -%}
        {%- endif -%}
    {%- endfor -%}

    {# If any customer-related columns are found, create a CTE selecting those columns #}
    {%- if customer_columns | length > 0 -%}
        with customer_columns as (
            select
                {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        )
    {# If no customer-related columns are found, create a CTE with a default column #}
    {%- else -%}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}