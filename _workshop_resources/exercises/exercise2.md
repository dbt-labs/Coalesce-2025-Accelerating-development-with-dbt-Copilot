# Exercise 2 - Amplifying Workflow

1. Open `models/marts/order_items.sql`

2. Open dbt Copilot SQL
   
3. Enter prompt
<ul>
Generate a source to target mapping document from this model. 
Include a column that defines the transformation applied. 
When describing join logic, use the node that the data originates 
from and describe how it flows through CTEs. Include the join logic 
at the bottom of the document.
</ul>

4. Open `models/copilot_workshop/source_to_target_example.sql`
   
5. Enter a second prompt
<ul>
Using the information from the source-to-target mapping, 
sketch out a dbt model with those transformations and joins.
</ul>

6. Enter a third prompt
<ul>
Add a field to calculate the percentage of the product price 
that the supply cost accounts for.
</ul>

7. With the `source_to_target_example.sql` file open in Studio,
review the generated output and click "Add" to populate code the file.
   
8. Save the `models/copilot_workshop/source_to_target_example.sql` file

### Other Copilot Functions
9. With the `source_to_target_example.sql` file open in Studio,
click the dbt Copilot button, and select the *Documentation* option
   
10. Save the yml file that was just created
    
11. Go back to the `source_to_target_example.sql` tab
    
12. Click the dbt Copilot button, and select the *Generic tests* option
    
13. Save the yml file that has just been updated
    
14. Go back to the `source_to_target_example.sql`
    
15. Click the dbt Copilot button, and select the *Semantic model* option
    
16. Save the yml file that was just created
