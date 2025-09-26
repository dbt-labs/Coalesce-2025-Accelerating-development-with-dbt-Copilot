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

# Exercise 2 - Amplifying Workflow

1. Open `models/marts/order_items.sql`
2. Enter prompt <ul>Generate a source to target mapping document from this model. Include a column that defines the transformation applied. Include the join logic at the bottom of the document.</ul>
3. Open `models/copilot_workshop/source_to_target_example.sql`
4. Enter a second prompt <ul>Using this information, generate a dbt model.</ul>
5. Enter a third prompt <ul>Add a field to calculate the percentage of the product price that the supply cost accounts for.</ul>
6. With the `source_to_target_example.sql` file open in Studio, review the generated output and click "Add" to populate code the file.
7. Save the file
8. Click the dbt Copilot button, and select the *Documentation* option
9. Save the yml file that was just created
10. Go back to the `source_to_target_example.sql` tab
11. Click the dbt Copilot button, and select the *Generic tests* option
12. Save the yml file that has just been updated
13. Go back to the `source_to_target_example.sql`
14. Click the dbt Copilot button, and select the *Semantic model* option
15. Save the yml file that was just created

# Exercise 3 - Jinja Enabler

1. Open `macros/activity_status.sql`
2. Enter prompt <ul>Generate a dbt macro. The argument provided will be a column with a date datatype. Write a case statement that determines a status of 'active' if the column value is within the last year, and ‘inactive’ if it is not.</ul>
3. Review generated output and click "Add" button to populate code in your sql file.
4. Save the sql file.
5. Open `macros/customer_fields_cte.sql`
6. Enter prompt <ul>Generate code for a dbt macro as a general template. The macro will take a model as an argument. Retrieve all columns in the model. Create a select statement that selects all columns from the model that include the word 'customer', ignore case. Return the select statement if any columns are found. If no columns are found, return 'select null as col'.</ul>
7. Enter prompt <ul>Revise this code with comments explaining what the macro does.</ul>
8. Save the sql file.

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




