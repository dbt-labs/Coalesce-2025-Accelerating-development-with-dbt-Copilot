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
