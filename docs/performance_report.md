# Query Performance Benchmark

## Objective
Compare a category-level sales aggregation against a pre-aggregated
yearly category sales table in Snowflake.

## Test Setup
- Platform: Snowflake
- Database: RISHIKA_RETAIL_ANALYTICS_DB
- Schema: GOLD
- Source table: FCT_ORDER_ITEMS
- Optimized table: MART_CATEGORY_YEARLY_SALES
- Reporting period: Calendar year 2017

## Results

| Metric | Original Query | Pre-aggregated Query |
|---|---:|---:|
| Client-side elapsed time | 0.8854 seconds | 0.2838 seconds |
| Rows returned | 72 | 72 |

## Result Validation
A full outer join compared the category-level order counts and
revenue values between both approaches.

Mismatched category results: 0

## Optimization Approach
Created MART_CATEGORY_YEARLY_SALES, which stores yearly sales
aggregated by product category. Queries for yearly category reporting
can read this smaller summary rather than aggregate the full
order-item fact table each time.

## Interpretation and Limitations
The observed single-run elapsed time was approximately 68% lower
for the pre-aggregated query. This is a preliminary observation,
not a guaranteed performance improvement.

Timings can vary with Snowflake caching, warehouse state, network
conditions, and result fetching. The benchmark should be repeated
under comparable conditions before making stronger performance
claims. The pre-aggregated table also requires storage and refreshes
when source data changes.

## Materialized View Experiment

### Objective
Compare a native Snowflake materialized view with an aggregation
performed directly against the Gold fact table.

### Setup
- Warehouse: RISHIKA_RETAIL_ANALYTICS_WH (X-Small)
- Source table: GOLD.FCT_ORDER_ITEMS
- Materialized view: GOLD.MV_CATEGORY_REVENUE_EXPERIMENT
- Filter: calendar year 2017
- Grouping: product category
- Metric: sum of item revenue

### Results

| Metric | Original fact table | Materialized view |
|---|---:|---:|
| Query ID | 01c77af1-3203-7b09-0017-69ae0060bc82 | 01c77af1-3203-7b09-0017-69ae0060bcd2 |
| Query History duration | 86 ms | 105 ms |
| Query Profile execution time | 32 ms | 23 ms |
| Bytes scanned | 0.80 MB | 0.01 MB |
| Partitions scanned | 2 of 2 | 2 of 2 |
| Percentage scanned from cache | 100% | 100% |
| Profile scan operation | Table Scan | Materialized View Scan |

The category revenue results matched between the two queries.
The materialized-view query scanned approximately 98.75% fewer bytes
based on the displayed profile values.

### Interpretation and Limitations

The Query Profile shows that Snowflake used a Materialized View Scan.
Profile execution time was 23 ms for the materialized-view query versus
32 ms for the original query. However, Query History duration was
105 ms versus 86 ms, respectively.

Both queries reported 100% cache usage, and the dataset is small.
These are single-run observations, not a controlled benchmark. They
do not establish a reliable end-to-end latency improvement or a
generalizable cost reduction. The displayed timing metrics represent
different measurements and should not be treated as interchangeable.

Further repeated runs under comparable conditions would be needed
for a stronger performance conclusion.

## Clustering Key Experiment

### Objective
Compare the same category-level sales aggregation on the original
order-item fact table and a copy configured with a clustering key
on order purchase date.

### Setup
- Platform: Snowflake
- Warehouse: RISHIKA_RETAIL_ANALYTICS_WH (X-Small)
- Original table: GOLD.FCT_ORDER_ITEMS
- Experiment table: GOLD.FCT_ORDER_ITEMS_CLUSTERED_EXPERIMENT
- Clustering key: ORDER_PURCHASE_DATE
- Filter: calendar year 2017
- Grouping: product category
- Metrics: distinct order count and item revenue
- Rows returned: 72 for both queries

### Query Profile Results

| Metric | Original table | Clustered experiment |
|---|---:|---:|
| Query ID | 01c77afe-3203-7b0e-0017-69ae0060adee | 01c77afd-3203-7b0e-0017-69ae0060ada2 |
| Query History duration | Not recorded | 672 ms |
| Query Profile execution time | 478 ms | 500 ms |
| Bytes scanned | 4.09 MB | 4.19 MB |
| Percentage scanned from cache | 0.00% | 0.00% |
| Partitions scanned | 1 of 1 | 1 of 1 |
| Query insight | None detected | Filter with clustering key |

The category-level order counts and revenue values matched between
the two queries.

### Interpretation and Limitations

The clustered experiment did not demonstrate a performance improvement
in this run. Its Query Profile execution time was 500 ms, compared
with 478 ms for the original table. It also scanned slightly more
data (4.19 MB versus 4.09 MB).

Both tables scanned their only reported partition, so this experiment
did not demonstrate partition pruning. Snowflake identified the filter
on the clustering key, but that insight alone does not establish a
performance benefit.

These results are single-run observations on a small dataset and
should not be generalized to larger tables or different workloads.
Repeated tests under comparable conditions and a dataset with enough
micro-partitions to evaluate pruning would be needed for a stronger
conclusion.
