{% macro generate_schema_name(custom_schema_name=none, node=none) -%}
    {% set node_name = node.name %}
    {% set split_name = node_name.split('__') %}
    {{ split_name[0] | trim }}
{%- endmacro %}


{% macro generate_alias_name(custom_schema_name=none, node=none) -%}
    {% set node_name = node.name %}
    {% set split_name = node_name.split('__') %}
    {{ split_name[1] | trim }}
{%- endmacro %}



-- Este archivo es muy ingenioso: 
-- hackea el comportamiento por defecto de dbt para organizar 
-- tu base de datos basándose estrictamente en el nombre de tus archivos. 
-- La lógica busca el doble guion bajo (__) en el nombre de tu archivo .sql y 
-- lo parte en dos:

-- Lo que hay antes del __ se convierte en el nombre del Esquema 
-- (la carpeta en la base de datos).

-- Lo que hay después del __ se convierte en el nombre de la Tabla.

-- Ejemplo práctico: Si tu archivo se llama staging__customers.sql, 
-- dbt creará automáticamente una tabla llamada customers dentro de un 
-- esquema llamado staging. ¡Por eso tus archivos tienen esos nombres tan largos!