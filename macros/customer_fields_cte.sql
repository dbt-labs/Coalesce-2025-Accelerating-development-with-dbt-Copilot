{% macro select_customer_columns(model_name) %}
    {#- Query to retrieve all column names from the specified model -#}
    {%- set columns_query -%}
        select column_name
        from information_schema.columns
        where table_name = '{{ model_name }}'
    {%- endset -%}

    {#- Execute the query to get the list of columns -#}
    {%- set columns = run_query(columns_query) -%}

    {#- Initialize an empty list to store columns containing 'customer' -#}
    {%- set customer_columns = [] -%}

    {#- Iterate over the columns to find those containing 'customer' -#}
    {%- for column in columns -%}
        {%- if 'customer' in column['column_name'] | lower -%}
            {#- Add the column to the customer_columns list if it contains 'customer' -#}
            {%- do customer_columns.append(column['column_name']) -%}
        {%- endif -%}
    {%- endfor -%}

    {#- Check if any customer columns were found -#}
    {%- if customer_columns | length > 0 -%}
        {#- Create a CTE with the found customer columns -#}
        with customer_columns as (
            select {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        )
    {%- else -%}
        {#- If no customer columns are found, return a CTE with a null column -#}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}