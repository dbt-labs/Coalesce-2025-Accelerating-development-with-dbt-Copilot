# Exercise 1 - SQL Prompting

1. Open `models/copilot_workshop/recreate_customers.sql`
2. Enter prompt <ul>Bring in the `@stg_customers`, `@orders`, and `@order_items` models in CTE’s. Name the CTE’s customers, orders, and order items.</ul>
3. Enter a second prompt to revise, <ul>Add another CTE called `order_summary` that selects from the `orders` CTE and joins to the `order_items` CTE on `order_id`. Include the `customer_id` field.
I want to see the following summary fields: count of lifetime orders, the first order date, the last order date, the sum of product price as lifetime_spend_pretax, and the sum of order_total as lifetime_spend.</ul>
4. Enter a third prompt <ul>Join the `order_summary` CTE to the `customers` CTE using `customer_id`.  Select columns explicitly from each CTE in a new CTE named `final`.  
Add a case statement to the final CTE that refers to a customer as ‘current’ if they have ordered in the last year and ‘inactive’ if they have not.  
Add a select statement to select all from the `final` CTE.</ul>
5. Review generated output and click "Add" button to populate code in your sql file.
6. OPTIONAL: Enter a final prompt as a preview for the next exercise. <ul>Create a source to target mapping spreadsheet from this model.  Include a column that defines the transformation applied.</ul>
7. Final Query Example
```SQL
with customers as (
   select * from {{ ref('stg_customers') }}
),
orders as (
   select * from {{ ref('orders') }}
),
order_items as (
   select * from {{ ref('order_items') }}
),
order_summary as (
   select
       o.customer_id,
       count(distinct o.order_id) as lifetime_orders,
       min(o.order_date) as first_order_date,
       max(o.order_date) as last_order_date,
       sum(oi.product_price) as lifetime_spend_pretax,
       sum(o.order_total) as lifetime_spend
   from orders o
   inner join order_items oi on o.order_id = oi.order_id
   group by o.customer_id
),
final as (
   select
       c.customer_id,
       c.customer_name,
       os.lifetime_orders,
       os.first_order_date,
       os.last_order_date,
       os.lifetime_spend_pretax,
       os.lifetime_spend,
       case
           when datediff(year, os.last_order_date, current_date) < 1 then 'current'
           else 'inactive'
       end as customer_status
   from order_summary os
   inner join customers c on os.customer_id = c.customer_id
)
select *
from final
```

# Exercise 2 - Amplifying Workflow

1. Open `models/marts/order_items.sql`
2. Enter prompt <ul>Generate a source to target mapping document from this model. Include a column that defines the transformation applied. Include the join logic at the bottom of the document.</ul>
3. Open `models/copilot_workshop/source_to_target_example.sql`
4. Enter a second prompt <ul>Using this information, generate a dbt model.</ul>
5. Enter a third prompt <ul>Add a field to calculate the percentage of the product price that the supply cost accounts for.</ul>
6. With the `source_to_target_example.sql` file open in Studio, review the generated output and click "Add" to populate code the file.
7. Save the file
8. Final query example
   ```SQL
   with joined as (
   select
       stg_order_items.*,
       stg_orders.order_date,
       stg_products.product_name,
       stg_products.product_price,
       stg_products.is_food_item,
       stg_products.is_drink_item,
       supplies.supply_cost,
       (supplies.supply_cost / stg_products.product_price) * 100 as supply_cost_percentage
   from
       {{ ref('stg_order_items') }}
   left join
       {{ ref('stg_orders') }}
   on
       stg_order_items.order_id = stg_orders.order_id
   left join
       {{ ref('stg_products') }}
   on
       stg_order_items.product_id = stg_products.product_id
   left join
       {{ ref('supplies') }}
   on
       stg_order_items.product_id = supplies.product_id
     )
    select * from joined
   ```
### Other Copilot Functions
9. With the `source_to_target_example.sql` file open in Studio, click the dbt Copilot button, and select the *Documentation* option
10. Save the yml file that was just created
11. Go back to the `source_to_target_example.sql` tab
12. Click the dbt Copilot button, and select the *Generic tests* option
13. Save the yml file that has just been updated
14. Go back to the `source_to_target_example.sql`
15. Click the dbt Copilot button, and select the *Semantic model* option
16. Save the yml file that was just created

# Exercise 3 - Jinja Enabler

1. Open `macros/activity_status.sql`
2. Enter prompt <ul>Generate a dbt macro. The argument provided will be a column with a date datatype. Write a case statement that determines a status of 'active' if the column value is within the last year, and ‘inactive’ if it is not.</ul>
3. Review generated output and click "Add" button to populate code in your sql file.
4. Save the sql file.
5. Example macro
  ```SQL
  {% macro determine_status(date_column) %}
     case
         when {{ date_column }} >= dateadd(year, -1, current_date()) then 'active'
         else 'inactive'
     end
  {% endmacro %}
  ```

6. Open `macros/customer_fields_cte.sql`
7. Enter prompt <ul>Generate code for a dbt macro as a general template. The macro will take a model as an argument. Retrieve all columns in the model. Create a select statement that selects all columns from the model that include the word 'customer', ignore case. Return the select statement if any columns are found. If no columns are found, return 'select null as col'.</ul>
8. Enter prompt <ul>Revise this code with comments explaining what the macro does.</ul>
9. Save the sql file.
10. Example macro
```SQL
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
```

# Exercise 4 - Troubleshooting SQL

1. Open `models/marts/order_items.sql`
2. Delete the group by statement on line 37
3. Click Preview button to observe error
4. Enter prompt <ul>Review this query, what is causing a syntax error?</ul>

# Exercise 5 - Troubleshooting macros

1. Open `analyses/compile_complex_nested_macro.sql`
2. Click Compile and review result against expected result in the comment block.
3. Open `macros/complex_nested_logic.sql`
4. Open dbt Copilot SQL window
5. Enter prompt <ul>This macro is not returning the expected result, what are some potential problems?</ul>
6. Use the provided response to edit the macro code and save.
7. Return to `compile_complex_nested_macro.sql`
8. Compile to see if your results match the expected result in the comment block.




