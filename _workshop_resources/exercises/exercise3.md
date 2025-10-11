# Exercise 3 - Jinja Enabler

1. Open `macros/activity_status.sql`

2. Open dbt Copilot SQL
   
2. Enter prompt
<ul>
Generate a dbt macro. The argument provided will be a column 
with a date datatype. Write a case statement that determines 
a status of 'active' if the column value is within the last year, 
and ‘inactive’ if it is not.
Return as SQL.
</ul>

3. Review generated output and click "Add" button to populate code
in your sql file.
   
4. Save the sql file.
   
5. Open `macros/customer_fields_cte.sql`
   
6. Enter prompt
<ul>
Generate a dbt macro. The macro will take a model as an argument. 
The macro will determine information about the columns in the model.
First, retrieve all of the columns in the model. 
Second, determine if any of the columns have the word 'customer' in the column name.  
Ignore case.
Create a select statement that selects all columns  
that include the word 'customer' from the model provided. 
Return the select statement if any columns are found. 
If no columns are found, return 'select null as col'.
Write it to handle any model passed to it.
Return as SQL.
</ul>

7. Enter prompt
<ul>
Revise this code with comments explaining what the macro does.
</ul>

8. Copy and paste the general template into the sql file.

9. Save the sql file.
