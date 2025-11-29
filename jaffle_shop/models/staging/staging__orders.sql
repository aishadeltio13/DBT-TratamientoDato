with source as (

    select * from {{ source('raw', 'orders') }}

),

renamed as (

    select
        id as order_id,
        store_id as location_id,
        customer as customer_id,
        cast(ordered_at as date) as order_date
    from source

)

select * from renamed

-- raw_orders(ID,CUSTOMER,ORDERED_AT,STORE_ID) --> (order_id, location_id, costumer_id, order_date)
