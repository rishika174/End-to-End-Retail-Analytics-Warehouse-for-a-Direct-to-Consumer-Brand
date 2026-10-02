SELECT
    spend_date,
    marketing_channel,
    campaign_name,
    ad_spend,
    impressions,
    clicks,
    data_source
FROM {{ ref('slv_marketing_spend') }}
