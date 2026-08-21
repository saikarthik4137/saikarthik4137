{{ config(materialized='table') }}

WITH clean_data AS (

    SELECT *

    FROM {{ ref('stg_raw_json_data') }}

    WHERE id IS NOT NULL
      AND name IS NOT NULL
      AND TRIM(name) <> ''
      AND amount IS NOT NULL
      AND item_id IS NOT NULL
      AND price IS NOT NULL
      AND total_value IS NOT NULL

),

dedup AS (

    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY id, item_id
            ORDER BY
                raw_loaded_at DESC,
                updated_at DESC
        ) AS rn
    FROM clean_data

)

SELECT
    id,
    name,
    amount,
    created_at,
    is_active,
    unexpected,
    item_id,
    price,
    total_value,
    loaded_at,
    updated_at,
    pipeline_run_at,
    raw_loaded_at,
    file_name

FROM dedup
WHERE rn = 1