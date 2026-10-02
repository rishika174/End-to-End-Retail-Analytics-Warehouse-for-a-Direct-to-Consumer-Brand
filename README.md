# Retail Analytics Warehouse

An end-to-end retail analytics project built with Snowflake, dbt Core, Python, and Metabase. The project transforms raw e-commerce data into analytical models and business-facing dashboards.

## Project Overview

This project demonstrates a modern analytics workflow:
- Ingest raw retail datasets into Snowflake.
- Transform and organize data using dbt.
- Build fact tables, dimension tables, and analytical marts.
- Validate data using dbt tests.
- Visualize revenue trends and product category performance in Metabase.
- Compare query performance using pre-aggregated models.
- Demonstrate Snowflake Time Travel recovery.

## Technology Stack

- **Data Warehouse:** Snowflake
- **Transformation:** dbt Core, SQL
- **Ingestion and Utilities:** Python
- **Visualization:** Metabase
- **Containerization:** Docker
- **Version Control:** Git

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
Bronze and Silver Models
        |
        v
Gold Fact and Dimension Tables
        |
        v
Analytical Data Marts
        |
        v
Metabase Dashboard
```

## Data Sources

The project uses the Brazilian e-commerce dataset commonly known as the Olist dataset, covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and product category translations.

A separate marketing spend dataset contains **synthetic demonstration data**. Marketing performance outputs should not be interpreted as actual campaign-attributed revenue or verified ROAS.

## Data Warehouse and Modeling

The Snowflake database contains the following schemas:

- `RAW` — source data loaded into Snowflake.
- `BRONZE` — initial modeled copies of staging data.
- `SILVER` — cleaned and enriched data models.
- `GOLD` — fact tables, dimensions, and business-facing marts.

### Gold Models

Key models include:

- `FCT_ORDERS`
- `FCT_ORDER_ITEMS`
- `FCT_PAYMENTS`
- `FCT_MARKETING_SPEND`
- `DIM_CUSTOMER`
- `DIM_PRODUCT`
- `DIM_SELLER`
- `DIM_DATE`
- `MART_MONTHLY_SALES`
- `MART_PRODUCT_PERFORMANCE`
- `MART_SELLER_PERFORMANCE`
- `MART_CUSTOMER_COHORTS`
- `MART_PAYMENT_PERFORMANCE`
- `MART_MARKETING_PERFORMANCE`
- `MART_CATEGORY_YEARLY_SALES`

## Data Quality

dbt tests cover important data quality checks, including:
- Required values in key columns.
- Uniqueness of primary identifiers.
- Basic integrity checks on analytical models.

## Dashboard

The Metabase dashboard includes:

1. **Monthly Revenue Trend** — monthly revenue including freight, through August 2018.
2. **Top 10 Product Categories by Revenue** — categories ranked by total revenue.

The dashboard uses Snowflake as its data source and Metabase for visualization.

## Query Performance Comparison

A category-level annual revenue query was compared with a pre-aggregated analytical mart.

| Measurement | Result |
|---|---:|
| Baseline query elapsed time | 0.8854 seconds |
| Pre-aggregated query elapsed time | 0.2838 seconds |
| Baseline result rows | 72 |
| Optimized result rows | 72 |
| Mismatched category results | 0 |
| Approximate elapsed-time reduction | 68% |

These are observed timings from a single comparison run. Actual performance can vary due to caching, warehouse conditions, and network overhead.

See `docs/performance_report.md` for details.

## Snowflake Time Travel Recovery

A disposable demonstration table was used to test recovery of data from before an accidental update. The original values were recovered successfully, and the temporary demonstration tables were removed afterward.

See `docs/time_travel_recovery.md` for details.

## Prerequisites

- Python 3
- Snowflake account and appropriate warehouse permissions
- dbt Core with the Snowflake adapter
- Docker Desktop, for running Metabase locally

## Configuration

1. Configure the required Snowflake connection variables in a local `.env` file.
2. Configure the dbt profile in `~/.dbt/profiles.yml` using environment variables.
3. Place the source CSV files in the expected local data locations.
4. Keep credentials and raw data out of version control.

**Never commit `.env`, passwords, private keys, or other credentials.**

## Running dbt

Activate the project's Python virtual environment, load the required environment variables, and run:

```bash
dbt debug
dbt build
```

Run commands from the project root. Ensure the Snowflake profile and source data are configured before building the models.

## Running Metabase Locally

With Docker Desktop running:

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase:latest
```

Open `http://localhost:3000` in your browser, complete the initial setup, and connect Metabase to the Snowflake database and GOLD schema.

If a container named `metabase` already exists, start the existing container instead:

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
│   ├── performance_report.md
│   └── time_travel_recovery.md
├── ingestion/
├── macros/
├── models/
├── tests/
├── dbt_project.yml
├── snowflake-queries
└── README.md
```

## Limitations

- Customer and product dimensions represent current modeled attributes, not full historical SCD Type 2 tracking.
- Marketing spend is synthetic demonstration data.
- Query performance timings are environment-dependent.
- The source e-commerce dataset covers historical activity rather than live transactions.

## Future Improvements

- Add dashboard screenshots and documentation.
- Extend automated data quality and freshness checks.
- Add orchestration for scheduled ingestion and transformation.
- Improve dashboard filtering and business metric documentation.

