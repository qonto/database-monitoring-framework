---
title: Long running queries
---

# PostgreSQLLongRunningQueries

## Meaning

Alert is triggered when SQL queries run for an extended period.

## Impact

- Block WAL file rotation

- Could block vacuum operations

- Could block other queries due to locks

- Could lead to replication lag on replica

## Diagnosis

1. Open `PostgreSQL server live` dashboard

1. Click on the queries to get details

## Mitigation

1. Identify the PIDs of the long running queries

    {{< details title="SQL" open=false >}}
{{% sql "../postgresql/sql/list-long-running-transactions.sql" %}}
    {{< /details >}}

    Queries could be blocked in trying to acquire a lock, so pay particular attention at the `blocked_by` column. If you identify specific queries blocking others, note down their PIDs. Below is a focused view of current locks on the database:

    {{< details title="SQL" open=false >}}
{{% sql "../postgresql/sql/list-ongoing-locks.sql" %}}
    {{< /details >}}

1. Terminate in priority the blocking queries, if not enough, terminate the other long running queries

    {{% sql "sql/terminate_backend.sql" %}}

## Additional resources

n/a
