---
title: Exporter down
---

# SQLExporterDown

## Meaning

Alert is triggered when the SQL exporter don't report being up.

## Impact

The monitoring system is degraded. SQL exporter does not collect SQL metrics, alerts cannot be triggered.

## Diagnosis

1. **Look at SQL exporter logs**. The error messages (`level=error`) should explain why the exporter can't scrape metrics.

    Usually, the exporter can't connect to the PostgreSQL server due to network restrictions, authentication failure, missing permissions or timeout.

    {{< hint info >}}
**PostgreSQL required permissions**

The SQL exporter needs `pg_monitor` role and `LOGIN` options.
    {{< /hint >}}

1. **Look at PostgreSQL connection logs**

    You'll get an error message if PostgreSQL exporter connections are rejected by PostgreSQL.

1. **Check memory usage**

    Sometimes, when target number is too high, the pod can be OOMKilled.

## Mitigation

Identify and fix PostgreSQL connection issue.

## Additional resources

- <https://github.com/burningalchemist/sql_exporter>
