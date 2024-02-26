---
title: Long running query
---

# PostgreSQLLongRunningQuery

## Meaning

Alert is triggered when a PostgreSQL query runs for an extended period.

## Impact

- Block WAL file rotation

- Could block vacuum operations

- Could block other queries due to locks

- Could lead to replication lag on replica

## Diagnosis

1. Find the PID(s) of queries by running `pg_active_backend_duration_minutes{ usename=...,datname=...,target=... }`

1. Open `PostgreSQL server live` dashboard

1. Click on the query to get details

## Mitigation

1. Cancel the query

    {{% sql "sql/cancel_backend.sql" %}}

1. If query is not cancelled, kill the query

    {{% sql "sql/terminate_backend.sql" %}}

## Additional resources

n/a
