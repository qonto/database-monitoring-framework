---
title: Exporter scraping limit
---

# PostgreSQLExporterScrapingLimit

## Meaning

Alert is triggered when Prometheus takes too long to fetch the PostgreSQL exporter metrics

## Impact

The monitoring system is degraded. PostgreSQL exporter does not collect PostgreSQL metrics, alerts cannot be triggered.

## Diagnosis

1. Check CPU and IOPS usage of the PostgreSQL server

    An overloaded server may have difficulty collecting metrics.

1. Check `prometheus-postgresql-exporter` logs

## Mitigation

1. Identify and kill heavy queries

    <details>
    <summary>How terminate a query?</summary>

    {{% sql "sql/terminate_backend.sql" %}}

    </details>

## Additional resources

n/a
