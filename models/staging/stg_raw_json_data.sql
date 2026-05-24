{{ config(materialized='table') }}

WITH flattened_data AS (

    SELECT
        RAW_DATA:id::INT AS id,

        TRIM(RAW_DATA:name::STRING) AS name,

        TRY_CAST(RAW_DATA:amount::STRING AS FLOAT) AS amount,

        TRY_TO_DATE(RAW_DATA:created_at::STRING) AS created_at,

        CASE
            WHEN LOWER(RAW_DATA:is_active::STRING) IN ('true', 'yes')
                THEN TRUE
            ELSE FALSE
        END AS is_active,

        RAW_DATA:extra_field:unexpected::STRING AS unexpected,

        f.VALUE:item_id::INT AS item_id,

        TRY_TO_NUMBER(f.VALUE:price::STRING) AS price,

        TRY_TO_NUMBER(f.VALUE:price::STRING)
        * TRY_CAST(RAW_DATA:amount::STRING AS FLOAT) AS total_value,

        CURRENT_TIMESTAMP() AS loaded_at,

        CURRENT_TIMESTAMP() AS updated_at,

        CURRENT_TIMESTAMP() AS pipeline_run_at,

        COALESCE(
            RAW_LOADED_AT,
            CURRENT_TIMESTAMP()
        ) AS raw_loaded_at,

        NULL AS file_name

    FROM {{ source('sales_db', 'raw_json_data') }},
    LATERAL FLATTEN(INPUT => RAW_DATA:nested:items) f
),

clean_data AS (

    SELECT *
    FROM flattened_data
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