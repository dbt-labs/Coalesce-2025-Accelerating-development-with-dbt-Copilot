{% macro select_customer_columns(model_name) %}
    {%- set columns_query -%}
        select column_name
        from information_schema.columns
        where table_name = '{{ model_name }}'
    {%- endset -%}

    {%- set columns = run_query(columns_query) -%}

    {%- set customer_columns = [] -%}

    {%- for column in columns -%}
        {%- if 'customer' in column['column_name'] | lower -%}
            {%- do customer_columns.append(column['column_name']) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- if customer_columns | length > 0 -%}
        with customer_columns as (
            select {{ customer_columns | join(', ') }}
            from {{ ref(model_name) }}
        )
    {%- else -%}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}