with

locations as (

    select * from {{ ref('staging__locations') }}

)

select * from locations

-- Información sobre las tiendas.