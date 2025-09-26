# Exercise 3 - Jinja Enabler

1. Open `macros/activity_status.sql`
   
2. Enter prompt
<ul>Generate a dbt macro. The argument provided will be a column with a date datatype. Write a case statement that determines a status of 'active' if the column value is within the last year, and ‘inactive’ if it is not.</ul>

3. Review generated output and click "Add" button to populate code in your sql file.
   
4. Save the sql file.
   
5. Open `macros/customer_fields_cte.sql`
   
6. Enter prompt
<ul>Generate code for a dbt macro as a general template. The macro will take a model as an argument. Retrieve all columns in the model. Create a select statement that selects all columns from the model that include the word 'customer', ignore case. Return the select statement if any columns are found. If no columns are found, return 'select null as col'.</ul>

7. Enter prompt
<ul>Revise this code with comments explaining what the macro does.</ul>

8. Save the sql file.
