-- Modelo incremental
{{ config(materialized='incremental') }}

select * from {{ source('raw', 'orders') }}

{% if is_incremental() %}
    -- Solo procesar datos nuevos
    where ordered_at > (select max(ordered_at) from {{ this }})
{% endif %}

-- Importante destacar que estamos leyendo de la tabla raw
-- "La primera vez que corras, crea la tabla normal."
-- "Las siguientes veces, no la borres. Prepárate para añadir datos nuevos."


