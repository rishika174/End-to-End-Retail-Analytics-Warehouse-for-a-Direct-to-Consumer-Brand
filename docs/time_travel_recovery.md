# Snowflake Time Travel Recovery Demos

## Objective

Demonstrate two Snowflake recovery capabilities using disposable test tables:
1. Recover a previous table state after an accidental data update.
2. Restore a table after it has been dropped.

## Demo 1: Recovering an Accidental Update

### Procedure

1. Created a disposable table named `GOLD.TT_RECOVERY_DEMO`.
2. Inserted two rows with the status `original`.
3. Updated both rows to `accidentally_changed`.
4. Retrieved the successful UPDATE statement ID from Snowflake query history.
5. Used Snowflake Time Travel with `BEFORE (STATEMENT => ...)` to create a separate recovered table named `GOLD.TT_RECOVERY_RESTORED`.

### Validation

The recovered table contained the original values:

| ID | STATUS |
|---:|---|
| 1 | original |
| 2 | original |

Recovery was verified by querying the restored table.

## Demo 2: Recovering a Dropped Table

### Procedure

1. Created `GOLD.TT_UNDROP_RECOVERY_DEMO_20261003`.
2. Inserted two rows with IDs `1` and `2`, both having the status `original`.
3. Queried the table and confirmed both rows existed.
4. Dropped the disposable table using `DROP TABLE`.
5. Restored the table using Snowflake's `UNDROP TABLE` command.
6. Queried the restored table to verify the original data.

### Validation

The restored table contained both original rows:

| ID | STATUS |
|---:|---|
| 1 | original |
| 2 | original |

The successful `UNDROP TABLE` operation and the restored data were verified in Snowflake.

## Safety Notes

Both demonstrations used disposable test tables, not production analytics tables. Time Travel recovery depends on Snowflake's retention configuration and applicable retention limits. These demonstrations illustrate recovery from an accidental data change or table drop; they are not a replacement for backups or a complete disaster recovery strategy.
