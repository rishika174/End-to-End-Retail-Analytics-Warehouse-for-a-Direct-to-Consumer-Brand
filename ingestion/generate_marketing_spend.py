from pathlib import Path

import pandas as pd

output_path = Path("data/raw/marketing_spend.csv")
output_path.parent.mkdir(parents=True, exist_ok=True)

months = pd.date_range("2016-09-01", "2018-10-01", freq="MS")

channels = {
    "paid_search": {
        "campaign": "Search Campaign",
        "base_spend": 4500,
        "base_impressions": 120000,
        "base_clicks": 6000,
    },
    "paid_social": {
        "campaign": "Social Campaign",
        "base_spend": 3200,
        "base_impressions": 180000,
        "base_clicks": 4500,
    },
    "display": {
        "campaign": "Display Campaign",
        "base_spend": 2200,
        "base_impressions": 250000,
        "base_clicks": 2500,
    },
    "email": {
        "campaign": "Email Campaign",
        "base_spend": 800,
        "base_impressions": 50000,
        "base_clicks": 4000,
    },
}

rows = []

for month_index, month in enumerate(months):
    for channel, details in channels.items():
        # Deterministic variation for reproducible demonstration data.
        factor = 1 + (month_index % 6) * 0.04

        rows.append({
            "spend_date": month.date().isoformat(),
            "marketing_channel": channel,
            "campaign_name": details["campaign"],
            "ad_spend": round(details["base_spend"] * factor, 2),
            "impressions": round(details["base_impressions"] * factor),
            "clicks": round(details["base_clicks"] * factor),
            "data_source": "synthetic_demo_data",
        })

df = pd.DataFrame(rows)
df.to_csv(output_path, index=False)

print(f"Created: {output_path}")
print(f"Rows: {len(df)}")
print(df.head(8).to_string(index=False))
print("\nIMPORTANT: All marketing metrics are synthetic demonstration data.")
