{% macro determine_status(date_column) %}
    -- This macro takes a date column as an argument and returns a status based on its value.
    case
        -- If the date in the column is within the last year from the current date, return 'active'.
        when {{ date_column }} >= dateadd(year, -1, current_date) then 'active'
        -- Otherwise, return 'inactive'.
        else 'inactive'
    end
{% endmacro %}