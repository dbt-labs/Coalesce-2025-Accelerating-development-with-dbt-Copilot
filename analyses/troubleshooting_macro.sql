{# 
Compiling this code should return the following result

[[12, 15, 19, 3], [13, 18]]

What is wrong with the macro definition?
#}


{% macro complex_nested_logic(input_list) %}
    {% set result = [] %}
    {% for item in input_list %}
        {% set sub_result = [] %}
        {% for sub_item in item.sub_items %}
            {% if sub_item.condition %}
                {% set total_value = sub_item.value %}
                {% for extra in sub_item.extras %}
                    {% if extra.flag %}
                        {% set total_value = total_value + extra.amount %}
                    {% endif %}
                {% endfor %}
                {% do sub_result.append(total_value) %}
            {% endif %}
        {% endfor %}
        {% do result.append(sub_result) %}
    {% endfor %}
    {{ return(result) }}
{% endmacro %}