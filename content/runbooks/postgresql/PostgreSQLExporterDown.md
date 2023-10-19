---
title: Exporter down
---

# PostgreSQLExporterDown

## Meaning

Alert is triggered when the PostgreSQL exporter can't fetch any metrics.

## Impact

The monitoring system is degraded. PostgreSQL exporter does not collect PostgreSQL metrics, alerts cannot be triggered.

## Diagnosis

1. Look at Prometheus PostgreSQL exporter logs. The error messages (`level=error`) should explain why the exporter can't scrape metrics.

    Usually, the exporter can't connect to the PostgreSQL server due to network restrictions, authentication failure, missing permissions or timeout.

    {{< hint info >}}
**PostgreSQL required permissions**

The PostgreSQL exporter needs `pg_monitoring` role and `LOGIN` options.
    {{< /hint >}}

1. Look at PostgreSQL connection logs

    You'll get an error message if PostgreSQL exporter connections are rejected by PostgreSQL.

## Mitigation

Identify and fix PostgreSQL connection issue.

## Additional resources

- <https://github.com/prometheus-community/postgres_exporter>
