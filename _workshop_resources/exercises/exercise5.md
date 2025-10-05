# Exercise 5 - Troubleshooting macros

1. Open `analyses/troubleshooting_macro.sql`
  
2. Click Compile and review result against expected result in the comment block.
  
3. Open `macros/complex_nested_logic.sql`
  
4. Open dbt Copilot SQL window

5. Enter prompt
<ul>
This macro is returning an empty list, what is the most likely cause of this?
</ul>

6. Use the provided response to edit the macro code and save it.

7. Return to `analyses/troubleshooting_macro.sql` and compile

8. The macro now returns values, but they are not quite correct.
    
9. Return to `compile_complex_nested_macro.sql`

10. Ask Copilot to identify this issue by provided your inputs
<ul> 
When providing this input:
{{ complex_nested_logic( input_list = [ { 'sub_items': [ { 'condition': True, 'value': 6,
'extras': [ {'flag': True, 'amount': 5},
{'flag': True, 'amount': 8},
], }, { 'condition': False, 'value': 3,
'extras': [ {'flag': False, 'amount': 10}, ], }, ], }, { 'sub_items': [ { 'condition': True, 'value': 4,
'extras': [ {'flag': True, 'amount': 6},
], }, ], }, ] )}}

I expect a result of [[12, 15, 19, 3], [13, 18]]
But I am getting a result of [[6, 15, 19, 3], [4, 18]]

What is the most likely cause?
</ul>

11. Use the provided response to edit the macro code and save it.

12. Return to `analyses/troubleshooting_macro.sql` and compile to check!
  
