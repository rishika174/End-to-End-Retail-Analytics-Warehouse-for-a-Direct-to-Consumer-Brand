SELECT
    DATE_TRUNC('MONTH', order_purchase_date)::DATE AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(*) AS total_order_items,
    SUM(item_revenue) AS total_item_revenue,
    SUM(freight_value) AS total_freight_value,
    SUM(item_total_amount) AS total_revenue_including_freight,
    AVG(item_revenue) AS average_item_price,
    AVG(delivery_delay_days) AS average_delivery_delay_days
FROM {{ ref('fct_order_items') }}
WHERE order_purchase_date IS NOT NULL
GROUP BY 1
ORDER BY 1
