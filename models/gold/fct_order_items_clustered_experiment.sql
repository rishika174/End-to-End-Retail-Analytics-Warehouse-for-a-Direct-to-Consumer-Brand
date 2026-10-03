{{ config(
    materialized='table',
    cluster_by=['order_purchase_date']
) }}

SELECT *
FROM {{ ref('fct_order_items') }}
