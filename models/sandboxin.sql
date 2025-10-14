select {{ select_customer_columns('recreate_customers') }}

-- Use the CTE in a query
select *
from customer_columns;