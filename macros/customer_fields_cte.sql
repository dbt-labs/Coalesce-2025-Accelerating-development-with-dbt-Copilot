{% macro select_customer_columns(model_name) %}
    {#- Construct a query to retrieve all column names from the information_schema.columns for the given model name -#}
    {%- set columns_query -%}
        select column_name
        from information_schema.columns
        where table_name = '{{ model_name }}'
    {%- endset -%}

    {#- Execute the query and store the result in the 'columns' variable -#}
    {%- set columns = run_query(columns_query) -%}

    {#- Initialize an empty list to store column names that contain 'customer' -#}
    {%- set customer_columns = [] -%}

    {#- Iterate over each column name retrieved from the query -#}
    {%- for column in columns -%}
        {#- Check if 'customer' is in the column name, ignoring case -#}
        {%- if 'customer' in column['column_name'] | lower -%}
            {#- If 'customer' is found, add the column name to the customer_columns list -#}
            {%- do customer_columns.append(column['column_name']) -%}
        {%- endif -%}
    {%- endfor -%}

    {#- Check if any customer-related columns were found -#}
    {%- if customer_columns | length > 0 -%}
        {#- If found, create a CTE named customer_columns selecting those columns from the model -#}
        with customer_columns as (
            select {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        )
    {%- else -%}
        {#- If no customer-related columns are found, create a CTE with a placeholder column -#}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}