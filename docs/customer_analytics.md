# Customer Analytics

## Overview

This project includes three customer analytics models in the GOLD schema:
- `MART_CUSTOMER_RETENTION`
- `MART_CUSTOMER_PURCHASE_BEHAVIOR`
- `DIM_CUSTOMER_SCD2`

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

## 3. DIM_CUSTOMER_SCD2

Reconstructs customer address versions in the GOLD schema using a Type 2 Slowly Changing Dimension (SCD2) pattern.

Key fields:
- `CUSTOMER_VERSION_KEY`: Unique key for each customer address version.
- `CUSTOMER_ID`: Customer record identifier from the source data.
- `CUSTOMER_UNIQUE_ID`: Identifier used to associate records belonging to the same customer.
- `CUSTOMER_ZIP_CODE_PREFIX`, `CUSTOMER_CITY`, `CUSTOMER_STATE`: Address attributes.
- `VALID_FROM`: Inferred start date for the address version.
- `VALID_TO`: End date of the version; NULL indicates the current version.
- `IS_CURRENT`: Boolean flag indicating whether the version is current.

### SCD2 approach

Customer records are associated with their first observed order purchase date. Address snapshots are ordered by effective date, and a new version is retained when the ZIP code, city, or state changes.

The `VALID_TO` date is derived from the next retained version's `VALID_FROM` date. A NULL `VALID_TO` identifies the latest retained version. This allows historical address versions to be queried rather than keeping only the current address.

### Validation

Automated dbt tests check:
- Version-key uniqueness and required fields.
- Valid Boolean values for `IS_CURRENT`.
- Exactly one current version per customer.
- Valid effective date ranges, where an end date exists.

### Important limitation

The source dataset does not provide actual address-change timestamps or a complete address-change log. `VALID_FROM` is inferred from the first order purchase date associated with each source customer record. Therefore, this model demonstrates the SCD2 structure using reconstructed address history; it should not be interpreted as a verified record of when a customer's address actually changed.

## Data Limitations

- Results depend on the time range and completeness of the source dataset.
- Customer retention measures repeat purchases, not customer activity on a website.
- One-time versus repeat classification is based on distinct orders with valid purchase dates.
- Customer address history is inferred from transaction dates rather than source-provided change timestamps.
