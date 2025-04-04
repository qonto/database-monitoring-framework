---
weight: 400
bookSearchExclude: true
---

# Architecture

## Overview

![Architecture direct](/architecture.png)

## Components

### Prometheus RDS exporter

The [Prometheus RDS exporter](https://github.com/qonto/prometheus-rds-exporter) collects key metrics from the different AWS APIs (RDS, Cloudwatch, EC2, and ServiceQuota) to have the full picture of servers's hardware capacity and utilization.

This component is optional but highly recommended for AWS customers.

### PostgreSQL exporter

A generic [SQL exporter](https://github.com/burningalchemist/sql_exporter) collects PostgreSQL internal metrics using system tables.

We have our own set of collectors, retrieving metrics to trigger advanced alerts and analyze trends over time. All our collectors for PostgreSQL can be found in [postgresql-collectors](https://github.com/qonto/postgresql-collectors).

This component is optional but highly recommended to analyze PostgreSQL metrics over time.

### Prometheus alerts

Monitoring alerts are defined in Prometheus rule format and work out of the box with the RDS and SQL exporters in Kubernetes environment with Prometheus operator.

They are distributed via Helm chart for convenient deployment:

| Helm chart | Description |
| --- | --- |
| [prometheus-rds-alerts-chart](https://gallery.ecr.aws/qonto/prometheus-rds-alerts-chart) | Alerts for AWS RDS |
| [prometheus-postgresql-alerts-chart](https://gallery.ecr.aws/qonto/prometheus-postgresql-alerts-chart) | Alerts for PostgreSQL |

These charts deploy [Prometheus `PrometheusRule`](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/alerting.md#deploying-prometheus-rules) Kubernetes resources. So Prometheus automatically discovers the alerts.

### Runbooks

Runbooks are hosted on <https://qonto.github.io/database-monitoring-framework> for convenience.

It's a static website generated using [Hugo](https://gohugo.io/) with [book template](https://github.com/alex-shpak/hugo-book).

## Deployment

While it's initially designed to be deployed in AWS + Kubernetes environment, Helm charts could be deployed in any Kubernetes cluster.
