{% macro select_customer_columns(model_name) %}
    {#- Construct a query to retrieve all column names from the information_schema for the given model -#}
    {%- set columns_query -%}
        select column_name
        from information_schema.columns
        where table_name = '{{ model_name }}'
    {%- endset -%}

    {#- Execute the query to get the list of columns -#}
    {%- set columns = run_query(columns_query) -%}

    {#- Initialize an empty list to store column names that contain 'customer' -#}
    {%- set customer_columns = [] -%}

    {#- Iterate over the retrieved columns -#}
    {%- for column in columns -%}
        {#- Check if the column name contains 'customer' (case-insensitive) -#}
        {%- if 'customer' in column['column_name'] | lower -%}
            {#- If it does, add the column name to the customer_columns list -#}
            {%- do customer_columns.append(column['column_name']) -%}
        {%- endif -%}
    {%- endfor -%}

    {#- If there are any customer-related columns, create a CTE selecting those columns -#}
    {%- if customer_columns | length > 0 -%}
        with customer_columns as (
            select {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        )
    {#- If no customer-related columns are found, create a CTE with a placeholder column -#}
    {%- else -%}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}