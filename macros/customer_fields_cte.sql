{% macro select_customer_columns(model_name) %}
    {# Retrieve all columns for the given model #}
    {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
    {%- set customer_columns = [] -%}
    
    {# Loop through each column to check if 'customer' is in the column name #}
    {%- for column in columns -%}
        {%- if 'customer' in column.name | lower -%}
            {# Add column to the list if it contains 'customer' #}
            {%- do customer_columns.append(column.name) -%}
        {%- endif -%}
    {%- endfor -%}

    {# Check if any customer-related columns were found #}
    {%- if customer_columns | length > 0 -%}
        {# Create a CTE selecting all customer-related columns #}
        with customer_columns as (
            select
                {%- for col in customer_columns -%}
                    {{ col }}{{ "," if not loop.last }}
                {%- endfor -%}
            from {{ ref(model_name) }}
        )
    {%- else -%}
        {# If no customer-related columns, return a CTE with 'select null as col' #}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}