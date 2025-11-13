{% macro select_customer_columns(model_name) %}
    {#- Construct a query to retrieve all column names from the information_schema.columns for the given model -#}
    {%- set columns_query -%}
        select column_name
        from information_schema.columns
        where table_name = '{{ model_name }}'
    {%- endset -%}

    {#- Execute the query to get the list of columns -#}
    {%- set columns = run_query(columns_query) -%}

    {#- Initialize an empty list to store column names that contain 'customer' -#}
    {%- set customer_columns = [] -%}

    {#- Iterate over the columns and check if 'customer' is in the column name, ignoring case -#}
    {%- for column in columns -%}
        {%- if 'customer' in column['column_name'] | lower -%}
            {#- If 'customer' is found, add the column name to the customer_columns list -#}
            {%- do customer_columns.append(column['column_name']) -%}
        {%- endif -%}
    {%- endfor -%}

    {#- If any customer columns are found, create a CTE selecting those columns -#}
    {%- if customer_columns | length > 0 -%}
        with customer_columns as (
            select 
                {{ customer_columns | join(', ') }}
            from {{ model_name }}
        )
    {#- If no customer columns are found, create a CTE with a single null column -#}
    {%- else -%}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}