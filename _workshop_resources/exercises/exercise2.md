# Exercise 2 - Amplifying Workflow

1. Open `models/marts/order_items.sql`
   
2. Enter prompt
<ul>Generate a source to target mapping document from this model. Include a column that defines the transformation applied. Include the join logic at the bottom of the document.</ul>

3. Open `models/copilot_workshop/source_to_target_example.sql`
   
4. Enter a second prompt
<ul>Using this information, generate a dbt model.</ul>

5. Enter a third prompt
<ul>Add a field to calculate the percentage of the product price that the supply cost accounts for.</ul>

6. With the `source_to_target_example.sql` file open in Studio, review the generated output and click "Add" to populate code the file.
   
7. Save the file

### Other Copilot Functions
8. With the `source_to_target_example.sql` file open in Studio, click the dbt Copilot button, and select the *Documentation* option
   
9. Save the yml file that was just created
    
10. Go back to the `source_to_target_example.sql` tab
    
11. Click the dbt Copilot button, and select the *Generic tests* option
    
12. Save the yml file that has just been updated
    
13. Go back to the `source_to_target_example.sql`
    
14. Click the dbt Copilot button, and select the *Semantic model* option
    
15. Save the yml file that was just created
