SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    price + freight_value AS item_total_amount
FROM {{ ref('br_order_items') }}
WHERE order_id IS NOT NULL
  AND order_item_id IS NOT NULL
  AND price IS NOT NULL
  AND price >= 0
  AND freight_value IS NOT NULL
  AND freight_value >= 0
