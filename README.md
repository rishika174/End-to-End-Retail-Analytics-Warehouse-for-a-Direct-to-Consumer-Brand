# End-to-End Retail Analytics Warehouse

An end-to-end retail analytics project built using Snowflake, dbt Core, Python, and Metabase. The project transforms historical e-commerce data into analytical models, business metrics, and interactive dashboards.

## Project Objectives

- Ingest retail data into Snowflake using Python.
- Organize transformations using a Medallion-style architecture.
- Build fact tables, dimension tables, and business-facing analytical marts.
- Validate data using dbt tests.
- Analyze sales, product performance, payments, and customer purchasing behavior.
- Visualize business metrics in Metabase.
- Compare detailed queries with pre-aggregated analytical models.
- Demonstrate Snowflake Time Travel recovery.

## Technology Stack

| Component | Technology |
|---|---|
| Cloud data warehouse | Snowflake |
| Data transformation | dbt Core, SQL |
| Ingestion and utilities | Python |
| Data visualization | Metabase |
| Containerization | Docker |
| Version control | Git and GitHub |

## Architecture

```text
Retail CSV Datasets
        |
        v
Python Ingestion
        |
        v
Snowflake RAW
        |
        v
dbt Staging Models
        |
        v
BRONZE Layer
        |
        v
SILVER Layer
        |
        v
GOLD Fact Tables and Dimensions
        |
        v
Analytical Data Marts
        |
        v
Metabase Dashboard
```

<img width="550" height="546" alt="image" src="https://github.com/user-attachments/assets/de1094d8-084a-45c9-a9a1-a598cde61e1a" />


## Data Sources

The primary dataset is the Brazilian e-commerce dataset commonly known as the Olist dataset. It contains historical data covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and product category translations.

Marketing spend is represented by a separate synthetic demonstration dataset. Marketing performance outputs are exploratory and must not be interpreted as actual campaign-attributed revenue or verified ROAS.

## Data Warehouse and Modeling

The Snowflake database uses the following schemas:

- `RAW` — source data loaded into Snowflake.
- `STAGING` — dbt staging views over source data.
- `BRONZE` — initial modeled copies of staging data.
- `SILVER` — cleaned and enriched models.
- `GOLD` — fact tables, dimensions, and analytical marts.

### Key Gold Models

**Fact tables**
- `FCT_ORDERS`
- `FCT_ORDER_ITEMS`
- `FCT_PAYMENTS`
- `FCT_MARKETING_SPEND`

**Dimensions**
- `DIM_CUSTOMER`
- `DIM_PRODUCT`
- `DIM_SELLER`
- `DIM_DATE`
- `DIM_CUSTOMER_SCD2` — reconstructed Type 2 customer address history.

**Analytical marts**
- `MART_MONTHLY_SALES`
- `MART_PRODUCT_PERFORMANCE`
- `MART_SELLER_PERFORMANCE`
- `MART_CATEGORY_YEARLY_SALES`
- `MART_PAYMENT_PERFORMANCE`
- `MART_CUSTOMER_COHORTS`
- `MART_CUSTOMER_RETENTION`
- `MART_CUSTOMER_PURCHASE_BEHAVIOR`
- `MART_CUSTOMER_LIFETIME_VALUE`
- `MART_EXECUTIVE_KPIS`
- `MART_MARKETING_PERFORMANCE`

### Customer Analytics

- **Customer retention:** Measures repeat purchasing by first-purchase cohort and activity month.
- **Purchase behavior:** Classifies customers as one-time or repeat purchasers based on observed distinct orders.
- **Customer address history:** Reconstructs address versions with `VALID_FROM`, `VALID_TO`, and `IS_CURRENT`; effective dates are inferred from order history.
- **Executive KPIs:** Provides aggregate revenue, order count, unique customers, and average order value.
- **Historical customer value:** Summarizes historical revenue, distinct orders, average order value, first and last purchase dates, and observed purchasing lifespan for each customer.

Customer retention is transaction-based; it does not measure website engagement or subscription retention. Purchase classifications describe historical observations and do not predict future behavior. The customer lifetime value model reports historical revenue, not predicted future value or profit; revenue includes item totals and freight, without deducting costs.

See `docs/customer_analytics.md` for model definitions and limitations.

## Data Quality and Build Validation

dbt tests cover required values, uniqueness, and accepted values for selected analytical columns.

The latest successful `dbt build` completed with:

| Result | Count |
|---|---:|
| Table models | 39 |
| View models | 10 |
| Data tests | 31 |
| Total operations | 80 |
| Warnings | 0 |
| Errors | 0 |

Build results reflect the project state at the time of the run.

## Metabase Dashboard

The `Retail Analytics Dashboard` includes four KPI cards:

- Total Revenue
- Total Orders
- Unique Customers
- Average Order Value

It also includes four visualizations:

1. **Monthly Revenue Trend** — monthly revenue including freight, through August 2018.
2. **Top 10 Product Categories by Revenue** — categories ranked by total revenue.
3. **Customer Cohort Retention** — repeat-purchase retention by cohort and elapsed month.
4. **Customer Purchase Type Distribution** — one-time versus repeat customers.

The dashboard uses Snowflake's GOLD schema as its data source.

## Query Performance Comparison

A category-level annual revenue query was compared with a pre-aggregated analytical mart.

| Measurement | Result |
|---|---:|
| Detailed query elapsed time | 0.8854 seconds |
| Pre-aggregated query elapsed time | 0.2838 seconds |
| Rows returned by each query | 72 |
| Mismatched category results | 0 |
| Approximate elapsed-time reduction | 68% |

These timings are from a single comparison run. Actual performance may vary with caching, warehouse conditions, and network overhead. The comparison demonstrates equivalent results for the tested queries, not a guaranteed performance improvement for every workload.

See `docs/performance_report.md` for details.

## Snowflake Time Travel Recovery

Two recovery demonstrations were performed using disposable test tables:

1. **Recovery after an update:** Used Snowflake Time Travel with a statement reference to recover the previous data state into a separate table.
2. **Recovery after a table drop:** Used `UNDROP TABLE` to restore a dropped table and verified that its original rows were present.

Both demonstrations were verified in Snowflake. The demonstrations illustrate recovery capabilities and are not a replacement for backups or a complete disaster recovery strategy.

See `docs/time_travel_recovery.md` for the procedures and validation results.

## Prerequisites

- Python 3
- Snowflake account and appropriate warehouse permissions
- dbt Core and the Snowflake adapter
- Docker Desktop for local Metabase deployment
- The required source CSV files

## Configuration

1. Configure Snowflake connection variables in a local `.env` file.
2. Configure the dbt profile in `~/.dbt/profiles.yml` using environment variables.
3. Place source CSV files in the locations expected by the ingestion scripts.
4. Ensure credentials and private configuration files remain outside version control.

Never commit `.env` files, passwords, private keys, or other credentials.

## Running dbt

From the project root, activate the virtual environment and load the environment variables required by your local configuration.

```bash
source .venv/bin/activate
set -a
source .env
set +a

dbt debug
dbt build
```

The Snowflake profile, permissions, and source data must be configured before building the models.

## Running Metabase Locally

With Docker Desktop running, start Metabase using:

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase:latest
```

Open `http://localhost:3000` in a browser, complete the initial setup, and connect Metabase to the Snowflake database and GOLD schema.

If a container named `metabase` already exists, start it instead:

```bash
docker start metabase
```

## Repository Structure

```text
retail-analytics-warehouse/
├── dashboard/
├── data/
├── data_generation/
├── docs/
│   ├── customer_analytics.md
│   ├── performance_report.md
│   └── time_travel_recovery.md
├── ingestion/
├── macros/
├── models/
│   ├── staging/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── tests/
├── dbt_project.yml
├── README.md
└── snowflake-queries
```

## Limitations

- The source dataset represents historical e-commerce activity, not live transactions.
- Marketing spend is synthetic demonstration data; actual campaign attribution and verified ROAS are not established.
- The standard customer dimension uses current attributes; `DIM_CUSTOMER_SCD2` separately reconstructs address history using inferred effective dates.
- Performance measurements are environment-dependent and based on a single comparison run.
- Customer retention measures observed repeat purchasing, not website engagement.
- Customer purchase classifications are descriptive and not predictive.
- `MART_CUSTOMER_LIFETIME_VALUE` describes historical revenue and observed purchasing lifespan; it does not predict future customer value or calculate profit.

## Future Improvements

- Add automated ingestion and transformation orchestration.
- Expand data freshness, relationship, and business-rule testing.
- Add more dashboard filters and documented business definitions.
- Add validated campaign attribution and customer acquisition cost analysis when suitable data becomes available.
