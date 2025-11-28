-- Modelo incremental
{{ config(materialized='incremental') }}

select * from {{ source('raw', 'orders') }}

{% if is_incremental() %}
    -- Solo procesar datos nuevos
    where created_at > (select max(created_at) from {{ this }})
{% endif %}