SELECT
    REVIEW_ID AS review_id,
    ORDER_ID AS order_id,
    TRY_TO_NUMBER(REVIEW_SCORE) AS review_score,
    NULLIF(TRIM(REVIEW_COMMENT_TITLE), '') AS review_comment_title,
    NULLIF(TRIM(REVIEW_COMMENT_MESSAGE), '') AS review_comment_message,
    TRY_TO_TIMESTAMP_NTZ(REVIEW_CREATION_DATE) AS review_creation_date,
    TRY_TO_TIMESTAMP_NTZ(REVIEW_ANSWER_TIMESTAMP) AS review_answer_timestamp
FROM {{ source('raw', 'ORDER_REVIEWS') }}
