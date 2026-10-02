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
