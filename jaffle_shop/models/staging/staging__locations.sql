with

source as (

    select * from {{ source('raw', 'stores') }}

),

renamed as (
    select
        id as location_id,
        name as location_name,
        tax_rate,
        cast(opened_at as date) as opened_date
    from source
)

select * from renamed

-- raw_stores(id,name,opened_at,tax_rate) --> (location_id, location_name,tax_rate, opened_date)
-- Importancia del cast:

-- En tu archivo original (raw_stores.csv), la columna opened_at probablemente viene como texto (ej: "2016-09-01") o como un "Timestamp" con horas, minutos y segundos (ej: "2016-09-01 00:00:00").

-- Sin el cast: La base de datos podría tratarlo como una cadena de texto cualquiera. Si luego intentaras hacer cálculos (ej: opened_date + 30 days), fallaría o daría resultados raros.

-- Con cast(opened_at as date): Le estás obligando a la base de datos a entender que eso es una FECHA.

-- Elimina la "basura" (las horas 00:00:00 que no aportan nada).

-- Habilita funciones de tiempo (filtrar por año, restar fechas, etc.).
