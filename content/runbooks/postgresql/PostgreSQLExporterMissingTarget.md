---
title: Exporter target down
---

# PostgreSQLExporterMissingTarget

## Meaning

Alert is triggered when a target (an instance or a database) isn't reachable by the SQL exporter. It can be a symptom of an underlying issue.

## Impact

The monitoring system is degraded for this target. SQL exporter does not collect SQL metrics, alerts cannot be triggered.

## Diagnosis

1. **Look at Prometheus SQL exporter logs**. The error messages (`level=error`) should explain why the exporter can't scrape metrics.

    Usually, the exporter can't connect to the PostgreSQL server due to network restrictions, authentication failure, missing permissions or timeout.

    {{< hint info >}}
**PostgreSQL required permissions**

The PostgreSQL exporter needs `pg_monitor` role and `LOGIN` options.
    {{< /hint >}}

1. **Look at PostgreSQL connection logs**

    You'll get an error message if PostgreSQL exporter connections are rejected by PostgreSQL.

## Mitigation

Identify and fix PostgreSQL connection issue.

## Additional resources

- <https://github.com/burningalchemist/sql_exporter>
