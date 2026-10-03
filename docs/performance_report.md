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
