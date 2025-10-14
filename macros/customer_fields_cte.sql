{% macro check_customer_columns(model_name) %}
    {# Retrieve all columns from the specified model using the adapter's get_columns_in_relation function #}
    {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
    {# Initialize an empty list to store column names that contain 'customer' #}
    {%- set customer_columns = [] -%}
    {# Iterate over each column in the model #}
    {%- for column in columns -%}
        {# Check if the column name contains the word 'customer' (case-insensitive) #}
        {%- if 'customer' in column.name | lower -%}
            {# If it does, append the column name to the customer_columns list #}
            {%- do customer_columns.append(column.name) -%}
        {%- endif -%}
    {%- endfor -%}
    {# Return the list of column names that contain 'customer' #}
    {{ customer_columns }}
{% endmacro %}