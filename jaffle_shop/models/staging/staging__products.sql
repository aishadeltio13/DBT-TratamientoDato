with

source as (

    select * from {{ source('raw', 'products') }}

),

renamed as (
    select
        sku                                as product_id,
        name                               as product_name,
        type                               as product_type,
        description                        as product_description,
        price / 100                        as product_price,
        coalesce(type = 'jaffle', false)   as is_food_item,
        coalesce(type = 'beverage', false) as is_drink_item
    from source
)

select * from renamed

-- raw_products(date_added,sku,name,type,price,description) --> (product_ide, product_name, product_type, product_description,product_price, is_food_item, is_drink_item)

-- price / 100 as product_price --> todos los precios los tenemos que normalizar para tener consistencia.

-- Coalesce:

-- ¿Qué hace? Evalúa si el tipo es 'jaffle'. Si lo es, pone TRUE. Si no, pone FALSE. El coalesce asegura que si el campo viene vacío (NULL), no se rompa nada, simplemente asume que FALSE.

-- ¿Por qué es genial?

-- Facilita la vida al analista de BI (PowerBI/Tableau). En lugar de escribir filtros complejos con texto (WHERE type IN ('jaffle', 'sandwich', 'tostada')), simplemente usan un interruptor: WHERE is_food_item = TRUE.

-- Si mañana decides que las "tostadas" también son comida, solo cambias la lógica aquí y todos tus reportes se actualizan automáticamente.
