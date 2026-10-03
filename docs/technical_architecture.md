# Technical Architecture and Data Lineage

## 1. Overview

The End-to-End Retail Analytics Warehouse transforms historical Brazilian e-commerce data into structured analytical models and business-facing dashboards.

The project uses Python for ingestion, Snowflake for cloud data storage and querying, dbt Core for SQL transformations and testing, and Metabase for visualization.

The architecture follows a medallion-style progression from raw source data to cleaned, conformed, and business-oriented analytical models.

## 2. Technology Stack

| Layer | Technology | Responsibility |
|---|---|---|
| Ingestion | Python | Load source datasets into Snowflake |
| Data warehouse | Snowflake | Store raw data and analytical models |
| Transformation | dbt Core and SQL | Build layered models, facts, dimensions, and marts |
| Data quality | dbt tests | Validate selected uniqueness, required-value, and business constraints |
| Visualization | Metabase | Present KPIs, trends, categories, and customer retention |
| Containerization | Docker | Run Metabase locally |
| Version control | Git and GitHub | Track project code and documentation |

## 3. High-Level Architecture

```text
Historical E-commerce CSV Files
             |
             v
     Python Ingestion
             |
             v
       Snowflake RAW
             |
             v
    STAGING Views (dbt)
             |
             v
       BRONZE Models
             |
             v
       SILVER Models
    Cleaning and Enrichment
             |
             v
        GOLD Models
       /     |      \
      v      v       v
    Facts  Dimensions  Analytical Marts
                         |
                         v
                  Metabase Dashboard
```

Marketing spend is supplied separately as synthetic demonstration data. It is not actual advertising-platform spend.

## 4. Medallion Architecture

### RAW

The RAW schema stores the ingested source datasets, including customers, orders, order items, payments, reviews, products, sellers, geolocation, product category translations, and synthetic marketing spend.

The purpose of this layer is to preserve source data for downstream processing.

### STAGING

The STAGING schema contains dbt staging views over the source data. These provide a consistent starting point for transformations.

### BRONZE

The BRONZE schema contains the initial modeled copies of staging data. It provides an intermediate layer between source-aligned views and further transformations.

### SILVER

The SILVER schema contains cleaned and enriched models. Transformations prepare data for analytical use and provide reusable inputs to the Gold layer.

### GOLD

The GOLD schema contains fact tables, dimensions, and business-facing analytical marts. These models support reporting and dashboard queries.

## 5. Dimensional Modeling

The Gold layer follows a dimensional modeling approach, with fact tables for measurable business events and dimensions for descriptive attributes.

### Fact tables

| Model | Purpose |
|---|---|
| `FCT_ORDERS` | Order-level analytical records |
| `FCT_ORDER_ITEMS` | Order-item revenue and product-related analysis |
| `FCT_PAYMENTS` | Payment-level analysis |
| `FCT_MARKETING_SPEND` | Monthly synthetic marketing spend records |

### Dimensions

| Model | Purpose |
|---|---|
| `DIM_CUSTOMER` | Customer attributes used in analytics |
| `DIM_PRODUCT` | Product and category attributes |
| `DIM_SELLER` | Seller attributes |
| `DIM_DATE` | Date-related reporting attributes |
| `DIM_CUSTOMER_SCD2` | Reconstructed customer address history |

### Analytical marts

| Model | Purpose |
|---|---|
| `MART_MONTHLY_SALES` | Monthly sales trends |
| `MART_PRODUCT_PERFORMANCE` | Product performance analysis |
| `MART_SELLER_PERFORMANCE` | Seller performance analysis |
| `MART_CATEGORY_YEARLY_SALES` | Annual category-level revenue aggregation |
| `MART_PAYMENT_PERFORMANCE` | Payment method analysis |
| `MART_CUSTOMER_COHORTS` | Customer cohort activity |
| `MART_CUSTOMER_RETENTION` | Repeat-purchase retention by cohort |
| `MART_CUSTOMER_PURCHASE_BEHAVIOR` | One-time versus repeat customer classification |
| `MART_CUSTOMER_LIFETIME_VALUE` | Historical customer revenue and purchasing lifespan |
| `MART_EXECUTIVE_KPIS` | Aggregate business KPIs |
| `MART_MARKETING_PERFORMANCE` | Exploratory sales and synthetic marketing-spend comparison |

The clustered order-item model and native materialized view are separate performance experiments, not replacements for the regular analytical models.

## 6. Customer History and Analytics

### Reconstructed Type 2 history

`DIM_CUSTOMER_SCD2` stores address versions with `VALID_FROM`, `VALID_TO`, and `IS_CURRENT` attributes. It retains distinct reconstructed address versions and identifies the current version.

The source data does not provide actual address-change timestamps or a complete change-event log. Effective dates are inferred from the earliest order date associated with each source customer record. When multiple snapshots have the same inferred date, the model deduplicates them.

Therefore, this is reconstructed historical address information, not a complete record of actual address changes.

### Cohort retention

Customer cohorts are based on first observed purchase, and subsequent activity is evaluated by purchase month. Retention represents observed repeat purchasing rather than website engagement or subscription retention.

### Customer purchase behavior

Customers are classified as one-time or repeat purchasers based on their observed distinct orders. These categories describe historical behavior and do not predict future purchases.

### Historical customer value

`MART_CUSTOMER_LIFETIME_VALUE` summarizes historical revenue, distinct orders, average order value, first and last purchase dates, and observed purchasing lifespan.

It is descriptive historical revenue, not predictive customer lifetime value or profit. Costs are not deducted.

## 7. Marketing Analytics Limitations

Marketing spend is synthetic demonstration data. The marketing performance mart supports exploratory comparisons between sales and spend, but the project does not establish campaign-level revenue attribution, verified return on ad spend (ROAS), or validated customer acquisition cost (CAC).

These metrics require appropriate campaign, attribution, and acquisition-cost data.

## 8. Data Quality and Validation

dbt data tests validate selected model constraints, including required values, uniqueness, and business rules.

The SCD2 implementation also has tests for one current version per customer and valid date ranges. The project has previously passed a full dbt build, but the latest full build result should be rechecked before submission because performance experiment models were added afterward.

## 9. Performance Experiments

Two performance experiments are documented separately:

- A detailed order-item query compared with a pre-aggregated annual category revenue mart.
- A clustered order-item table and a native Snowflake materialized-view experiment.

The experiments compare result consistency and observed query timings. Timing results are sensitive to cache state, warehouse conditions, and query execution overhead. The materialized-view comparison showed lower bytes scanned and lower Query Profile execution time in the observed run, but did not establish a reliable end-to-end latency improvement.

See `docs/performance_report.md` for query IDs, observed timings, profile statistics, and limitations.

## 10. Time Travel Recovery

Snowflake Time Travel was demonstrated using disposable test tables:

- Recovery of an earlier table state after an update.
- Restoration of a dropped table using `UNDROP TABLE`.

The demonstrations were verified using the restored rows. They illustrate recovery capabilities and do not replace a full backup or disaster recovery strategy.

See `docs/time_travel_recovery.md` for the procedures and verification details.

## 11. Dashboard and Consumption Layer

Metabase connects to Snowflake and uses the Gold schema for business-facing analysis.

The Retail Analytics Dashboard includes:

- Total revenue
- Total orders
- Unique customers
- Average order value
- Monthly revenue trend
- Top product categories by revenue
- Customer cohort retention
- One-time versus repeat customer distribution

The dashboard provides a reporting interface over the warehouse's curated analytical models.

## 12. Limitations and Future Work

Current limitations include:

- Historical rather than live transaction data.
- Synthetic marketing spend without verified campaign attribution.
- Reconstructed rather than fully observed customer address history.
- Descriptive rather than predictive customer value.
- Performance observations based on limited runs and a small dataset.

Potential future improvements include automated orchestration, additional relationship and business-rule tests, repeated performance benchmarks under comparable conditions, and validated marketing attribution when suitable source data is available.
