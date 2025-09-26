{# Simple macro #}
{% macro determine_status(date_column) %}
     case
         when {{ date_column }} >= dateadd(year, -1, current_date()) then 'active'
         else 'inactive'
     end
{% endmacro %}


{# Complex macro #}
{% macro select_customer_columns(model) %}
   {# Retrieve all columns from the specified model #}
   {%- set columns = adapter.get_columns_in_relation(ref(model)) -%}
   {%- set customer_columns = [] -%}


   {# Iterate over each column to check if 'customer' is in the column name (case-insensitive) #}
   {%- for column in columns -%}
       {%- if 'customer' in column.name | lower -%}
           {# Add column to the list if it includes 'customer' #}
           {%- do customer_columns.append(column.name) -%}
       {%- endif -%}
   {%- endfor -%}


   {# Construct a select statement with the filtered columns or default to 'select null as col' if none are found #}
   {%- if customer_columns | length > 0 -%}
       select {{ customer_columns | join(', ') }}
   {%- else -%}
       select null as col
   {%- endif -%}
{% endmacro %}
