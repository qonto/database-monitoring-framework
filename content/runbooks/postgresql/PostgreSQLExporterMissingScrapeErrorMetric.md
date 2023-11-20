---
title: Exporter missing scrape error metric
---

# PostgreSQLExporterMissingScrapeErrorMetric

## Meaning

Alert is triggered when Prometheus doesn't collect the last scrape error metric for the Prometheus PostgreSQL exporter.

## Impact

Monitoring system is degraded. The exporter is either down or failing to expose some metrics.

## Diagnosis

1. Check Prometheus PostgreSQL exporter logs

## Mitigation

Identify and fix the errors reported by the exporter.

## Additional resources

- <https://github.com/prometheus-community/postgres_exporter>
