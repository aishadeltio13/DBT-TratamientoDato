with

source as (

    select * from {{ source('raw', 'supplies') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['id', 'sku']) }} as supply_uuid,
        id as supply_id,
        sku as product_id,
        name as supply_name,
        {{ cents_to_dollars('cost') }} as supply_cost,
        perishable as is_perishable_supply
    from source

)

select * from renamed

-- raw_supplies.csv(id,name,cost,perishable,sku) --> (supply_uuid, supply_id, product_id, supply_name, supply_cost, is_perishable_supply)

-- La Clave Subrogada (generate_surrogate_key): Aquí estás usando el paquete dbt_utils que vimos en packages.yml.
-- ¿Qué hace? Toma las columnas id y sku, las junta y genera un código alfanumérico largo y único (un "hash").
-- ¿Por qué es vital? A veces, un ID simple no es suficiente para identificar una fila única (quizás el mismo ID de suministro se repite para diferentes productos). 
-- Al crear esta clave "artificial" (UUID), garantizas que cada fila tenga una huella digital única imposible de duplicar. Es la base para hacer JOINS seguros más adelante.

-- {{ cents_to_dollars('cost') }} as supply_cost : Esto es una MACRO. Es una función.


