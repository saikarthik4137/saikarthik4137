{{ config(materialized='table') }}

WITH flattened_data AS (

    SELECT

        SRC:id::INT AS id,

        TRIM(SRC:name::STRING) AS name,

        TRY_CAST(SRC:amount::STRING AS FLOAT) AS amount,

        TRY_TO_DATE(SRC:created_at::STRING) AS created_at,

        CASE
            WHEN LOWER(SRC:is_active::STRING) IN ('true', 'yes')
                THEN TRUE
            ELSE FALSE
        END AS is_active,

        SRC:extra_field:unexpected::STRING AS unexpected,

        f.VALUE:item_id::INT AS item_id,

        TRY_TO_NUMBER(f.VALUE:price::STRING) AS price,

        TRY_TO_NUMBER(f.VALUE:price::STRING)
        - TRY_CAST(SRC:amount::STRING AS FLOAT) AS total_value,

        CURRENT_TIMESTAMP() AS loaded_at,

        CURRENT_TIMESTAMP() AS updated_at,

        CURRENT_TIMESTAMP() AS pipeline_run_at,

        COALESCE(
            RAW_LOADED_AT,
            CURRENT_TIMESTAMP()
        ) AS raw_loaded_at,

        NULL AS file_name

    FROM {{ source('sales_db', 'raw_json_data') }},
         LATERAL FLATTEN(INPUT => SRC:nested:items) f

)

SELECT *
FROM flattened_data