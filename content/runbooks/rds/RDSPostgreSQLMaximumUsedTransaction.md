---
title: Maximum used transactions
---
# RDSPostgreSQLMaximumUsedTransaction

## Meaning

Alert is triggered when a PostgreSQL server is closed from its maximum number of visible transactions hard limit.

{{< hint danger >}}
**Important**
It's a race against time to prevent PostgreSQL from shutting down to prevent data loss.
{{< /hint >}}

<details>
<summary>More</summary>

PostgreSQL uses Multi-Version Concurrency Control (MVCC) to provide data access concurrency.

Transaction IDs are stored in 32 bits integers, so PostgreSQL can have up to 4 billion visible transactions.

PostgreSQL continuously recycles transaction IDs once transactions are released.

If transactions are not released, PostgreSQL won't be able to accept new transactions (or queries).

PostgreSQL internal events:

- 40 million transactions before the upper limit is reached, WARNING messages consisting of a countdown will be logged
- 3 million transactions before the upper limit is reached, PostgreSQL goes to READ-ONLY mode

See https://www.postgresql.org/docs/15/routine-vacuuming.html
</details>

## Impact

**PostgreSQL will shut down** and refuse to start any new transactions once there are fewer than 3 million transactions left until wraparound.

## Diagnosis

Transaction ID Wraparound can be caused by a combination of one or more of the following circumstances:

- Check if there a long-running transactions on the `live dashboard`

    <details>
    <summary>SQL</summary>

    {{% sql "../postgresql/sql/list-long-running-transactions.sql" %}}

    </details>

- Check replication slots are active and don't have lag on `live dashboard`.

    PostgreSQL retains WAL files until the replication slot client confirms received data.
    <details>
    <summary>SQL</summary>

    {{% sql "sql/list-replication-slots.sql" %}}

    </details>

- Check the `autovacuum` is turned on

    Note: `autovacumm` could be disabled on specific tables

    <details>
    <summary>SQL</summary>

    {{% sql "sql/show-autovacuum.sql" %}}

    </details>

- Autovacuum can't be executed due to intense operations (SELECT, INSERT, UPDATE, DELETE)

- Check PostgreSQL vacuum logs

## Mitigation

1. Terminate long-running queries

1. Vacuum databases as quickly as possible to prevent a forced shutdown.

## Additional resources

- <https://blog.sentry.io/transaction-id-wraparound-in-postgres>
- <https://www.percona.com/blog/overcoming-vacuum-wraparound>
- <https://www.postgresql.org/docs/current/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND>
