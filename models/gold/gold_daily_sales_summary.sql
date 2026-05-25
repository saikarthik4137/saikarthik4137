{{ config(materialized='table') }}

SELECT

    -- =================================================
    -- DATE INFORMATION
    -- =================================================

    DATE(created_at) AS sales_date,

    DAYNAME(created_at) AS sales_day_name,

    MONTH(created_at) AS sales_month,

    YEAR(created_at) AS sales_year,


    -- =================================================
    -- SALES KPIs
    -- =================================================

    COUNT(DISTINCT id) AS total_orders,

    COUNT(*) AS total_rows,

    SUM(total_value) AS total_sales,

    AVG(total_value) AS avg_sales,

    MAX(total_value) AS max_sale,

    MIN(total_value) AS min_sale,


    -- =================================================
    -- CUSTOMER ANALYTICS
    -- =================================================

    COUNT(DISTINCT name) AS unique_customers,

    COUNT(DISTINCT CASE
        WHEN is_active = TRUE
        THEN id
    END) AS active_customers,

    COUNT(DISTINCT CASE
        WHEN is_active = FALSE
        THEN id
    END) AS inactive_customers,


    -- =================================================
    -- PRODUCT ANALYTICS
    -- =================================================

    COUNT(DISTINCT item_id) AS total_products,

    AVG(price) AS avg_product_price,

    MAX(price) AS highest_product_price,

    MIN(price) AS lowest_product_price,


    -- =================================================
    -- DATA QUALITY CHECKS
    -- =================================================

    COUNT(CASE
        WHEN amount < 0
        THEN 1
    END) AS negative_amount_records,

    COUNT(CASE
        WHEN price < 0
        THEN 1
    END) AS negative_price_records,

    COUNT(CASE
        WHEN name IS NULL
        THEN 1
    END) AS null_name_records,


    -- =================================================
    -- PIPELINE AUDIT COLUMNS
    -- =================================================

    MIN(raw_loaded_at) AS first_data_loaded_at,

    MAX(raw_loaded_at) AS latest_data_loaded_at,

    CURRENT_TIMESTAMP() AS pipeline_run_at


FROM {{ ref('fct_sales_incremental') }}

GROUP BY

    DATE(created_at),
    DAYNAME(created_at),
    MONTH(created_at),
    YEAR(created_at)

ORDER BY sales_date DESC