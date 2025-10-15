{% macro select_customer_columns(model_name) %}
    {#- Get a reference to the model using the ref function -#}
    {%- set relation = ref(model_name) -%}
    
    {#- Retrieve all columns from the model using the adapter.get_columns_in_relation function -#}
    {%- set columns = adapter.get_columns_in_relation(relation) -%}
    
    {#- Initialize an empty list to store column names that contain 'customer' -#}
    {%- set customer_columns = [] -%}

    {#- Loop through each column in the model -#}
    {%- for column in columns -%}
        {#- Check if 'customer' is in the column name (case-insensitive) -#}
        {%- if 'customer' in column.name | lower -%}
            {#- If true, append the column name to the customer_columns list -#}
            {%- do customer_columns.append(column.name) -%}
        {%- endif -%}
    {%- endfor -%}

    {#- Check if any customer columns were found -#}
    {%- if customer_columns | length > 0 -%}
        {#- If customer columns exist, create a CTE with those columns -#}
        with customer_columns as (
            select
                {%- for col in customer_columns -%}
                    {{ col }}{{ "," if not loop.last else "" }}
                {%- endfor -%}
            from {{ relation }}
        )
    {%- else -%}
        {#- If no customer columns exist, create a CTE with a placeholder column -#}
        with customer_columns as (
            select null as col
        )
    {%- endif -%}
{% endmacro %}