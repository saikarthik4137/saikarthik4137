{% snapshot clean_json_snapshot %}

{{
    config(
        target_schema='PUBLIC',
        unique_key='id',
        strategy='check',
        check_cols=['name', 'amount', 'is_active']
    )
}}

WITH source_data AS (

    SELECT
        TRY_TO_NUMBER(r.data:id::string) AS id,
        r.data:name::string AS name,
        TRY_TO_NUMBER(r.data:amount::string) AS amount,

        CASE 
            WHEN LOWER(r.data:is_active::string) IN ('true', 'yes') THEN TRUE
            WHEN LOWER(r.data:is_active::string) = 'false' THEN FALSE
            ELSE NULL
        END AS is_active,

        TRY_TO_TIMESTAMP(r.data:created_at::string) AS created_at

    FROM {{ source('raw_layer', 'raw_json_data') }} r

    WHERE TRY_TO_NUMBER(r.data:id::string) IS NOT NULL
),

deduplicated AS (

    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY id 
                   ORDER BY created_at DESC
               ) AS rn
        FROM source_data
    )
    WHERE rn = 1
)

SELECT * FROM deduplicated

{% endsnapshot %}