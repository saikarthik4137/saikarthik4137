{{ config(
    materialized='incremental',
    unique_key='id'
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
        raw_loaded_at,
        file_name,

        ROW_NUMBER() OVER (
            PARTITION BY id, item_id
            ORDER BY created_at DESC
        ) AS rn

    FROM {{ ref('stg_sales_clean') }}

),

final_data AS (

    SELECT *
    FROM source_data
    WHERE rn = 1

)

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
    raw_loaded_at,
    file_name

FROM final_data

{% if is_incremental() %}

WHERE updated_at >
(
    SELECT COALESCE(MAX(updated_at), '1900-01-01')
    FROM {{ this }}
)

{% endif %}