{% macro complex_nested_logic(input_list) %}
    {%- set result = [] -%}
    {% for item in input_list %}
        {% if item is not none %}
            {% set nested_result = [] %}
            {% for sub_item in item.sub_items %}
                {% if sub_item.condition %}
                    {% set processed_value = sub_item.value * 2 %}
                    {% if processed_value > 10 %}
                        {{ nested_result.append(processed_value) }}
                    {% else %}
                        {% set adjusted_value = processed_value + 5 %}
                        {{ nested_result.append(adjusted_value) }}
                    {% endif %}
                {% else %}
                    {{ nested_result.append(sub_item.value) }}
                {% endif %}
                {% set additional_processing = [] %}
                {% for extra in sub_item.extras %}
                    {% if extra.flag %}
                        {% set extra_value = extra.amount * 3 %}
                        {% if extra_value < 20 %}
                            {{ additional_processing.append(extra_value) }}
                        {% else %}
                            {{ additional_processing.append(extra_value - 5) }}
                        {% endif %}
                    {% endif %}
                {% endfor %}
                {{ nested_result.extend(additional_processing) }}
            {% endfor %}
            {{ result.append(nested_result) }}
        {% endif %}
    {% endfor %}
    {{ return(result) }}
{% endmacro %}