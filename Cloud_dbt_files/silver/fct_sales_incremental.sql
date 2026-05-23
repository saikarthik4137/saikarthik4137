{{ config(
    materialized='incremental',
    unique_key='id'
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
    RAW_LOADED_AT

FROM {{ ref('stg_sales_clean') }}

{% if is_incremental() %}

WHERE RAW_LOADED_AT >
(
    SELECT MAX(RAW_LOADED_AT)
    FROM {{ this }}
)

{% endif %}