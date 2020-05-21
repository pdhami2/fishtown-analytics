
{% macro generate_references(refs) %}

    {% if refs is mapping %}

        with
        {% for index in refs %}
            {{index}} as (
                select * from {{ ref(refs[index]) }}
            )
            {%- if not loop.last -%}
                ,
            {%- endif -%}
        {%- endfor -%}

    {% else %}

        with
        {% for item in refs %}
            {{item}} as (
                select * from {{ ref(item) }}
            )
            {%- if not loop.last -%}
                ,
            {% endif %}
        {%- endfor -%}
    {%- endif -%}

{%- endmacro %}