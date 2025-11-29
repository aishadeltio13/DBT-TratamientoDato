with

source as (

    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        id as customer_id,
        name as customer_name
    from source
)

select * from renamed

-- raw_costumers(ID, Name) lo cambiamos a (costumer_id, costumer_name)

