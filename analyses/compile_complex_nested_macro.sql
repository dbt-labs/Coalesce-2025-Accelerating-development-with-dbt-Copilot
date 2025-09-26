{# 
Compiling this code should return the following result

[[12, 15, 19, 3], [13, 18]]

What is wrong with the macro definition?
#}


{{ complex_nested_logic(
    input_list = [
    {
        'sub_items': [
            {
                'condition': True,
                'value': 6,  
                'extras': [
                    {'flag': True, 'amount': 5},  
                    {'flag': True, 'amount': 8},  
                ],
            },
            {
                'condition': False,
                'value': 3,  
                'extras': [
                    {'flag': False, 'amount': 10},
                ],
            },
        ],
    },
    {
        'sub_items': [
            {
                'condition': True,
                'value': 4,  
                'extras': [
                    {'flag': True, 'amount': 6},  
                ],
            },
        ],
    },
]
)}}