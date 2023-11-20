---
title: Exporter Errors
---

# PostgreSQLExporterErrors

## Meaning

Alert is triggered when the PostgreSQL exporter reports errors when scrapping metrics.

## Impact

The monitoring system is degraded, some metrics may not be collected anymore. Alerts relying on these metrics will not trigger.

## Diagnosis

**Look at Prometheus PostgreSQL exporter logs**. The error messages (`level=error`) should explain why the exporter can't scrape metrics.

Usually, this is linked to misconfiguration of the exporter.

## Mitigation

Identify and fix the exporter misconfigurations.

## Additional resources

- <https://github.com/prometheus-community/postgres_exporter>
