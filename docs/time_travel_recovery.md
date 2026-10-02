# Snowflake Time Travel Recovery Demo

## Objective
Demonstrate recovery of a table's previous state after an accidental update.

## Test Procedure
1. Created a disposable table named `GOLD.TT_RECOVERY_DEMO`.
2. Inserted two rows with the status `original`.
3. Updated both rows to `accidentally_changed`.
4. Retrieved the successful UPDATE statement ID from Snowflake query history.
5. Used Snowflake Time Travel with `BEFORE (STATEMENT => ...)` to create
   a separate recovered table named `GOLD.TT_RECOVERY_RESTORED`.

## Recovery Validation

Expected recovered rows:

| ID | STATUS |
|---:|---|
| 1 | original |
| 2 | original |

Recovery was verified by querying the restored table.

## Safety Notes
The demonstration used disposable test tables, not production analytics
tables. Time Travel retention depends on Snowflake's table configuration
and retention limits. This demo illustrates recovery from an accidental
data change; it is not a replacement for backups or disaster recovery.
