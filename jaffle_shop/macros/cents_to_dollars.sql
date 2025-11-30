{# A basic example for a project-wide macro to cast a column uniformly #}

{% macro cents_to_dollars(column_name) -%}
    {{ return(adapter.dispatch('cents_to_dollars')(column_name)) }}
{%- endmacro %}

{% macro default__cents_to_dollars(column_name) -%}
    ({{ column_name }} / 100)::numeric(16, 2)
{%- endmacro %}

{% macro postgres__cents_to_dollars(column_name) -%}
    ({{ column_name }}::numeric(16, 2) / 100)
{%- endmacro %}

{% macro bigquery__cents_to_dollars(column_name) %}
    round(cast(({{ column_name }} / 100) as numeric), 2)
{% endmacro %}

{% macro fabric__cents_to_dollars(column_name) %}
    cast({{ column_name }} / 100 as numeric(16,2))
{% endmacro %}


-- Este archivo define una función matemática para convertir centavos a dólares 
-- (dividiendo por 100), pero su verdadera magia es que es polimórfica.
--  Fíjate en el comando adapter.dispatch: lo que hace es detectar 
--  automáticamente qué base de datos estás usando (Postgres, BigQuery, Fabric o DuckDB) 
--  y elegir la fórmula SQL sintácticamente correcta para esa base de datos específica. 
--  Gracias a esto, puedes escribir {{ cents_to_dollars('coste') }} en tus modelos 
--  y funcionará perfecto tanto en tu ordenador local como en la nube sin que tengas 
--  que cambiar ni una coma.