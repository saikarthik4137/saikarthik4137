{{ config(
    materialized='incremental',
    unique_key=['id', 'item_id']
) }}

WITH source_data AS (

    SELECT
        id,
        name,
        amount,
        created_at,
        is_active,
        item_id,
        price,
        total_value,
        loaded_at,
        updated_at,
        pipeline_run_at,
        raw_loaded_at

    FROM {{ ref('stg_sales_clean') }}

),

deduplicated AS (

    SELECT *

    FROM source_data

    QUALIFY ROW_NUMBER() OVER (

        PARTITION BY id, item_id

        ORDER BY
            updated_at DESC,
            raw_loaded_at DESC,
            created_at DESC,
            total_value DESC,
            name DESC

    ) = 1

)

SELECT *
FROM deduplicated

{% if is_incremental() %}

WHERE updated_at >
(
    SELECT COALESCE(MAX(updated_at), '1900-01-01')
    FROM {{ this }}
)

{% endif %}