{{ config(
    materialized='table'
) }}

SELECT *

FROM {{ ref('stg_sales_clean') }}