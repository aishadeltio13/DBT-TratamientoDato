with order_lineitems as (

    select * from {{ ref('staging__order_lineitems') }}

),

orders as (

    select * from {{ ref('staging__orders') }}

),

products as (

    select * from {{ ref('staging__products') }}

)



select
    orders.order_date,
    orders.location_id,
    orders.customer_id,
    order_lineitems.order_id,
    order_lineitems.product_id,
    products.product_type,
    sum(case when type_of_movement = 'VENTA' then order_lineitems.quantity else 0 end)       as original_quantity,
    sum(order_lineitems.quantity)                                                            as final_quantity,
    avg(order_lineitems.unit_price)                                                          as unit_price,
    sum(case when type_of_movement = 'VENTA' then order_lineitems.subtotal_price else 0 end) as original_subtotal_price,
    sum(order_lineitems.subtotal_price)                                                      as final_subtotal_price,
    max(type_of_movement == 'DEVOLUCION')                                                    as has_returned_items      
from 
    order_lineitems 
inner join 
    orders  
on order_lineitems.order_id = orders.order_id
inner join 
    products
on order_lineitems.product_id = products.product_id
group by 
    orders.order_date,
    orders.location_id,
    orders.customer_id,
    order_lineitems.order_id,
    order_lineitems.product_id,
    products.product_type



-- Estás cogiendo tablas limpias (orders, lineitems, products) y mezclándolas para crear una "Súper Tabla" que tenga toda la información junta.
-- Usas ref() para llamar a tus tablas de staging. Esto construye el Linaje (Lineage) de dbt. Si staging cambia, este modelo se enterará.

-- La Lógica del JOIN (La "Súper Tabla")
    -- Estás haciendo un cruce a tres bandas:
    -- Tomas los ítems (detalle).
    -- Le pegas la información del pedido (fecha, cliente, tienda) -> INNER JOIN orders.
    -- Le pegas la información del producto (tipo, categoría) -> INNER JOIN products.
        -- El Resultado: Cada fila de esta tabla te dice: "El Cliente X compró el Producto Y en la fecha Z, costó tanto y fue (o no) una devolución".

