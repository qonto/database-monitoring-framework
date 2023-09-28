---
title: Disk space prediction
---

# RDSDiskSpacePrediction

## Meaning

Alert is triggered when monitoring predict the RDS storage disk space will be full.

## Impact

The PostgreSQL instance will stop to prevent data corruption if no more disk space is available.

## Diagnosis

Determine whether it's a long-term growth trend requiring storage increase or abnormal disk usage reflecting another problem:

1. Check database size growth over the last 24 hours to identify abnormal disk usage growth

    Look at `Storage usage` panel in `RDS instance details` Grafana dashboard

1. Check if there are long-running transactions (or queries)

    Look at `Postgresql live activity` Grafana dashboard to find long-running query

    <details>
    <summary>Why?</summary>
    {{< postgresql-long-running-transaction-impacts >}}
    </details>

    {{< details title="PostgreSQL" open=false >}}
{{% sql "../postgresql/sql/list-long-running-transactions.sql" %}}
    {{< /details >}}

1. Check the status of PostgreSQL replication slots

    <details>
    <summary>Why?</summary>
    PostgreSQL keeps WAL files on its disk until the replication slot client acknowledges they consumed it.
    </details>

1. Check log file sizes

    <details>
    <summary>Why?</summary>
    PostgreSQL logs could consume large disk space.

    Usually related to:
    - Connection/disconnections
    - Slow queries
    - PGaudit logs
    - Internal errors
    - Temporary files

    PostgreSQL parameters:
    - `log_temp_files` can be set to log temporary file creation above a size threshold
    - `temp_file_limit` parameter can be set to avoid over-usage: <https://www.postgresql.org/docs/16/runtime-config-resource.html#RUNTIME-CONFIG-RESOURCE-DISK>
    </details>

## Mitigation

You must avoid reaching no disk space left situation.

- Fix the system that blocks PostgreSQL to recycle its WAL files

  - If long-running transactions/queries: cancel or kill the transactions
  - If non-running replication slot: delete replication slot

- Increase RDS disk space

    {{< hint warning >}}
{{% aws-rds-storage-increase-limitations %}}
{{< /hint >}}

## Additional resources

n/a
