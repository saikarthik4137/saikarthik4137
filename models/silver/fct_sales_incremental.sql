{{ config(
    materialized='incremental',
    unique_key=['id','item_id'],
    incremental_strategy='delete+insert',
    on_schema_change='sync_all_columns'
) }}

SELECT

    id,
    name,
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

FROM {{ ref('stg_sales_clean') }}

{% if is_incremental() %}

WHERE raw_loaded_at >
(
    SELECT COALESCE(MAX(raw_loaded_at), '1900-01-01')
    FROM {{ this }}
)

{% endif %}