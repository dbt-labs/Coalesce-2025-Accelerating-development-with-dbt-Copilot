{% macro select_customer_columns(model_name) %}
    
    {# Construct a query to retrieve all column names from the information_schema.columns for the specified model #}
    {% set query %}
        select
            column_name
        from
            information_schema.columns
        where
            table_name = '{{ model_name }}'
    {% endset %}

    {# Execute the query and store the results #}
    {% set results = run_query(query) %}
    
    {# Initialize an empty list to store column names that contain 'customer' #}
    {% set customer_columns = [] %}

    {# Iterate over the query results to find columns containing 'customer', ignoring case #}
    {% for row in results %}
        {% if 'customer' in row['column_name'] | lower %}
            {# Append the column name to the customer_columns list if it contains 'customer' #}
            {% do customer_columns.append(row['column_name']) %}
        {% endif %}
    {% endfor %}

    {# Check if any customer-related columns were found #}
    {% if customer_columns | length > 0 %}
        {# Construct a CTE with the found customer columns #}
        with customer_columns as (
            select
                {{ customer_columns | join(', ') }}
            from
                {{ ref(model_name) }}
        )
    {% else %}
        {# If no customer columns are found, return a CTE with a default column #}
        with customer_columns as (
            select null as col
        )
    {% endif %}
{% endmacro %}
