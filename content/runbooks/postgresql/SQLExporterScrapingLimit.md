---
title: Exporter scraping limit
---

# SQLExporterScrapingLimit

## Meaning

Alert is triggered when Prometheus takes too long to fetch the SQL exporter metrics

## Impact

The monitoring system is degraded. SQL exporter does not collect SQL metrics, alerts cannot be triggered.

## Diagnosis

1. Check CPU and IOPS usage of the PostgreSQL server

    An overloaded server may have difficulty collecting metrics.

2. Look at PostgreSQL Server logs to identify long running queries.

    You may need to enable [`log_min_duration_statement`](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT) to identify which queries are long to be executed.

## Mitigation

1. Identify and kill heavy queries

    <details>
    <summary>How to terminate queries?</summary>

    {{% sql "sql/terminate_backend.sql" %}}

    </details>

## Additional resources

n/a
