{% macro determine_status(date_column) %}
    case
        when {{ date_column }} >= dateadd(year, -1, current_date) then 'active'
        else 'inactive'
    end
{% endmacro %}

{% macro determine_status_dup(date_column) %}
    case
        when {{ date_column }} >= dateadd(year, -1, current_date) then 'active'
        else 'inactive'
    end
{% endmacro %}