SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM {{ ref('br_order_reviews') }}
WHERE review_id IS NOT NULL
  AND order_id IS NOT NULL
  AND review_score BETWEEN 1 AND 5
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY review_id
    ORDER BY review_creation_date DESC NULLS LAST
) = 1
