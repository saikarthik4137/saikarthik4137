{{ config(materialized='table') }}

SELECT

    created_at,

    COUNT(DISTINCT id) AS total_orders,

    SUM(total_value) AS total_sales,

    AVG(total_value) AS avg_sales,

    MAX(total_value) AS max_sale,

    MIN(total_value) AS min_sale

FROM {{ ref('fct_sales_incremental') }}

GROUP BY created_at