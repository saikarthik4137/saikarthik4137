{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='merge'
) }}

SELECT
    TRY_TO_NUMBER(r.data:id::string) AS id,
    r.data:name::string AS name,
    TRY_TO_NUMBER(r.data:amount::string) AS amount,

    CASE 
        WHEN LOWER(r.data:is_active::string) IN ('true', 'yes') THEN TRUE
        WHEN LOWER(r.data:is_active::string) = 'false' THEN FALSE
        ELSE NULL
    END AS is_active,

    TRY_TO_TIMESTAMP(r.data:created_at::string) AS created_at,

    CURRENT_TIMESTAMP() AS updated_at

FROM {{ source('raw_layer', 'raw_json_data') }} r

WHERE TRY_TO_NUMBER(r.data:id::string) IS NOT NULL