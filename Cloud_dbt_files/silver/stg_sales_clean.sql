{{ config(materialized='view') }}

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
        RAW_LOADED_AT

    FROM {{ ref('stg_raw_json_data') }}

    WHERE id IS NOT NULL
      AND name IS NOT NULL
      AND amount IS NOT NULL
      AND amount >= 0
      AND created_at IS NOT NULL
      AND price IS NOT NULL
      AND price >= 0
),

dedup AS (

    SELECT *,

        ROW_NUMBER() OVER (
            PARTITION BY id, item_id
            ORDER BY created_at DESC
        ) AS rn

    FROM clean_data
)

SELECT *

FROM dedup
WHERE rn = 1