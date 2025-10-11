# Exercise 3 - Jinja Enabler

1. Open `macros/activity_status.sql`

2. Open dbt Copilot SQL
   
2. Enter prompt
<ul>
Generate a dbt macro. The argument provided will be a column 
with a date datatype. Write a case statement that determines 
a status of 'active' if the column value is within the last year, 
and ‘inactive’ if it is not.
</ul>

3. Review generated output and click "Add" button to populate code
in your sql file.
   
4. Save the sql file.
   
5. Open `macros/customer_fields_cte.sql`
   
6. Enter prompt
<ul>
Generate a dbt macro. The macro will take a model as an argument. 
You do not need to know any schema information or any other 
context about the model because the macro is meant to determine this 
information about any given model. 
First, retrieve all of the columns in the model. 
Second, determine if any of the columns have the word 'customer' 
in the column name. Ignore case. 
</ul>

7. Add additional requirements in the next prompt
<ul>
Now modify this macro to create a select statement that 
selects all columns that include the word 'customer' 
from the model provided. 
If any columns are found, return the select statement 
in a CTE named customer_columns.
If no columns are found, return the CTE with 'select null as col'. 
Write it to handle any model passed to it. 
</ul>

8. Enter a third prompt
<ul>
Revise this code with comments explaining what the macro does.
</ul>

9. Copy and paste the macro code into the sql file.

10. Save the sql file.
