# Customer Analytics

## Overview

This project includes two customer analytics models in the GOLD schema.

## 1. MART_CUSTOMER_RETENTION

Tracks customer purchasing activity by the month of the first purchase.

Key fields:
- `COHORT_MONTH`: Month of the customer's first recorded purchase.
- `ACTIVITY_MONTH`: Month in which the customer purchased.
- `MONTHS_SINCE_FIRST_PURCHASE`: Number of calendar months between cohort and activity.
- `COHORT_SIZE`: Number of customers in the first-purchase cohort.
- `ACTIVE_CUSTOMERS`: Distinct cohort customers who purchased in the activity month.
- `RETENTION_RATE`: Active customers divided by the original cohort size.

The first-purchase month should have a retention rate of 1.0 for each cohort.
Later-month rates measure repeat purchasing in the available transaction data.

This is transaction-based retention, not website engagement or subscription retention.

## 2. MART_CUSTOMER_PURCHASE_BEHAVIOR

Provides one row per customer with a valid purchase date.

Key fields:
- `CUSTOMER_UNIQUE_ID`: Customer identifier used to combine orders belonging to the same customer.
- `TOTAL_ORDERS`: Number of distinct orders in the available dataset.
- `FIRST_PURCHASE_DATE`: Earliest recorded purchase date.
- `LAST_PURCHASE_DATE`: Latest recorded purchase date.
- `CUSTOMER_TYPE`: One-time Customer when total orders equal one; otherwise Repeat Customer.

The classification describes observed order history in this dataset. It does not establish whether a customer is newly registered or whether a customer will purchase again in the future.

## Data Limitations

- Results depend on the time range and completeness of the source dataset.
- Customer retention measures repeat purchases, not customer activity on a website.
- One-time versus repeat classification is based on distinct orders with valid purchase dates.
