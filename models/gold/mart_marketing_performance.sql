WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('MONTH', order_purchase_date)::DATE AS sales_month,
        SUM(item_revenue) AS total_sales_revenue,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customer_ids
    FROM {{ ref('fct_order_items') }}
    WHERE order_purchase_date IS NOT NULL
    GROUP BY 1
),

monthly_marketing AS (
    SELECT
        DATE_TRUNC('MONTH', spend_date)::DATE AS spend_month,
        marketing_channel,
        SUM(ad_spend) AS synthetic_ad_spend,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks
    FROM {{ ref('fct_marketing_spend') }}
    GROUP BY 1, 2
)

SELECT
    m.spend_month AS report_month,
    m.marketing_channel,
    m.synthetic_ad_spend,
    m.impressions,
    m.clicks,
    COALESCE(s.total_sales_revenue, 0) AS total_sales_revenue,
    COALESCE(s.total_orders, 0) AS total_orders,
    COALESCE(s.unique_customer_ids, 0) AS unique_customer_ids,
    ROUND(
        COALESCE(s.total_sales_revenue, 0)
        / NULLIF(m.synthetic_ad_spend, 0),
        2
    ) AS illustrative_sales_to_spend_ratio,
    'Synthetic marketing spend; sales are not campaign-attributed'
        AS metric_limitation
FROM monthly_marketing m
LEFT JOIN monthly_sales s
    ON m.spend_month = s.sales_month
