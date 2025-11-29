with source as (

    select * from {{ source('raw', 'items') }}

),

renamed as (
    select
        order_id              as order_id,
        id                    as lineitem_id,
        sku                   as product_id,
        price / 100           as unit_price,    
        units                 as quantity,
        units * (price / 100) as subtotal_price,
        case when units > 0 then 'VENTA' else 'DEVOLUCION' end as type_of_movement
    from source
)

select * from renamed

-- raw_items(id,order_id,sku,price,Units) --> (order_id, lineitem_id, product_ide, unit_price, quantity, subtotal_price)

--price / 100 as unit_price --> Estás convirtiendo ese entero técnico en un valor real y legible (dólares/euros) desde el primer momento.
--units * (price / 100) as subtotal_price --> En lugar de obligar a quien use esta tabla a calcular siempre cantidad * precio, ya se lo das pre-calculado.
-- case when units > 0 then 'VENTA' else 'DEVOLUCION' end as type_of_movement --> Estás clasificando las filas. Si units fuera negativo (algo común en devoluciones en algunos sistemas ERP), lo marcarías como 'DEVOLUCION'.