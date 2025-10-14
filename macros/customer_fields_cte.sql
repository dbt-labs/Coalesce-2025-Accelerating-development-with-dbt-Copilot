{% macro select_customer_columns(model_name) %}
    {#- Retrieve all columns from the specified model -#}
    {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
    {%- set customer_columns = [] -%}
    
    {#- Loop through each column to check if 'customer' is in the column name, ignoring case -#}
    {%- for column in columns -%}
        {%- if 'customer' in column.name | lower -%}
            {#- If 'customer' is found in the column name, add it to the customer_columns list -#}
            {%- do customer_columns.append(column.name) -%}
        {%- endif -%}
    {%- endfor -%}

    {#- Check if any customer columns were found -#}
    {%- if customer_columns | length > 0 -%}
        {#- If customer columns are found, create a CTE with those columns -#}
        with customer_columns as (
            select
                {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        )
    {%- else -%}
        {#- If no customer columns are found, create a CTE with a default null column -#}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}