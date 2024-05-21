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

1. Cancel the queries

    {{% sql "sql/cancel_backend.sql" %}}

1. If queries do not get cancelled, kill them

    {{% sql "sql/terminate_backend.sql" %}}

## Additional resources

n/a
