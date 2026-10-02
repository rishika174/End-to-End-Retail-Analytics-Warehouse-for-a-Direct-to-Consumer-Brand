SELECT
    spend_date,
    marketing_channel,
    campaign_name,
    ad_spend,
    impressions,
    clicks,
    data_source
FROM {{ ref('br_marketing_spend') }}
WHERE spend_date IS NOT NULL
  AND marketing_channel IS NOT NULL
  AND ad_spend IS NOT NULL
  AND ad_spend >= 0
  AND impressions IS NOT NULL
  AND impressions >= 0
  AND clicks IS NOT NULL
  AND clicks >= 0
