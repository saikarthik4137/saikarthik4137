{{ config(materialized='table') }}

select

    created_at,

    count(distinct id) as total_orders,

    sum(total_value) as total_sales,

    avg(total_value) as avg_sales,

    max(total_value) as max_sale,

    min(total_value) as min_sale

from {{ ref('fct_sales_incremental') }}

where created_at IS NOT NULL

group by created_at