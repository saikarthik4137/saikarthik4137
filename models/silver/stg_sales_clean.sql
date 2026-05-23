{{ config(
    materialized='table'
) }}

WITH clean_data AS (

    SELECT

        id,
        TRIM(name) AS name,
        amount,
        created_at,
        is_active,
        item_id,
        price,
        total_value,

        CURRENT_TIMESTAMP() AS loaded_at,
        CURRENT_TIMESTAMP() AS updated_at,
        CURRENT_TIMESTAMP() AS pipeline_run_at,

        raw_loaded_at

    FROM {{ ref('stg_raw_json_data') }}

),

dedup AS (

    SELECT *,

        ROW_NUMBER() OVER (
            PARTITION BY id, item_id
            ORDER BY raw_loaded_at DESC
        ) AS rn

    FROM clean_data
)

SELECT *

FROM dedup
WHERE rn = 1