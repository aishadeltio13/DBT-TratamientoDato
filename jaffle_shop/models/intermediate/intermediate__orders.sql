-- with order_lineitems as (

--     select * from {{ ref('staging__order_lineitems') }}

-- ),

-- orders as (

--     select * from {{ ref('staging__orders') }}

-- )



-- -- Este modelo tiene mucha complejidad. ¿La podriamos reducir?
-- select
--     orders.order_date,
--     orders.location_id,
--     orders.customer_id,
--     order_lineitems.order_id,
--     count(distinct order_lineitems.product_id) as numper_of_products,
--     sum(case when type_of_movement = 'VENTA' then order_lineitems.quantity else 0 end)       as original_quantity,
--     sum(order_lineitems.quantity)                                                            as final_quantity,
--     sum(case when type_of_movement = 'VENTA' then order_lineitems.subtotal_price else 0 end) as original_subtotal_price,
--     sum(order_lineitems.subtotal_price)                                                      as final_subtotal_price,
--     max(type_of_movement == 'DEVOLUCION')                                                    as has_returned_items      
-- from 
--     order_lineitems 
-- inner join 
--     orders  
-- on order_lineitems.order_id = orders.order_id
-- group by 
--     orders.order_date,
--     orders.location_id,
--     orders.customer_id,
--     order_lineitems.order_id,


with orders as (

    select * from {{ ref('staging__orders') }}

),

line_items as (

    select * from {{ ref('staging__order_lineitems') }}

),

-- PASO 1: Calcular métricas aisladas (sin mezclar con clientes ni fechas todavía).
-- Aquí tomamos la lista de productos (que tiene muchas filas por cada pedido) 
-- y la "comprimimos" para que quede una sola fila por pedido con todos sus totales.

order_metrics as (

    select
        order_id,
        count(distinct product_id) as number_of_products,
        
        -- Métricas de Cantidad
        sum(case when type_of_movement = 'VENTA' then quantity else 0 end) as original_quantity,
        sum(quantity) as final_quantity,
        
        -- Métricas de Dinero
        sum(case when type_of_movement = 'VENTA' then subtotal_price else 0 end) as original_subtotal_price,
        sum(subtotal_price) as final_subtotal_price,
        
        -- Banderas (Booleanos)
        max(case when type_of_movement = 'DEVOLUCION' then 1 else 0 end) = 1 as has_returned_items

    from line_items
    group by 1

),

-- PASO 2: Unir lo calculado con la información del pedido (Join limpio 1:1).
-- Ahora que tenemos las métricas calculadas, 
-- solo nos falta pegarles la información de "contexto" (quién compró, cuándo y dónde).

final as (

    select
        orders.order_id,
        orders.location_id,
        orders.customer_id,
        orders.ordered_at as order_date, -- Ojo: verifica si en staging lo llamaste 'ordered_at'
        
        -- Traemos las métricas ya calculadas, usando COALESCE por si un pedido no tiene ítems (raro, pero posible)
        coalesce(order_metrics.number_of_products, 0) as number_of_products,
        coalesce(order_metrics.original_quantity, 0) as original_quantity,
        coalesce(order_metrics.final_quantity, 0) as final_quantity,
        coalesce(order_metrics.original_subtotal_price, 0) as original_subtotal_price,
        coalesce(order_metrics.final_subtotal_price, 0) as final_subtotal_price,
        coalesce(order_metrics.has_returned_items, false) as has_returned_items

    from orders
    left join order_metrics using (order_id) -- 'using' es un atajo elegante si la columna se llama igual

)

select * from final
