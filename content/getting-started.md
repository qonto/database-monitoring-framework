---
title: Getting started
weight: 1
---

# Getting started

This Database Monitoring Framework is designed to work in *Kubernetes* and *Prometheus operator* environment, but it could be used in different environments.

## Quick deployment

{{< hint info >}}
**Tips**

Look at [architecture page]({{< relref "architecture.md" >}}) to understand the role of each component.

See also our tutorials for concrete deployment example.
{{< /hint >}}

Steps to deploy the framework on on your infrastructure:

1. Deploy Prometheus operator

    Make sure:
    - `serviceMonitorSelector` is defined to enable `ServiceMonitor` ([documentation](https://github.com/prometheus-operator/prometheus-operator/blob/v0.68.0/Documentation/user-guides/alerting.md#deploying-prometheus-rules))
    - `ruleSelector` is enabled for `PrometheusRules` ([documentation](https://github.com/prometheus-operator/prometheus-operator/blob/v0.68.0/Documentation/user-guides/alerting.md#deploying-prometheus-rules))

1. Deploy Prometheus RDS exporters and/or PostgreSQL exporter as describe in tutorials

1. Deploy charts with helm

    ```bash
    # RDS alerts
    helm install prometheus-rds-alerts-chart oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart:{{% current_version %}} --namespace ${KUBERNETES_NAMESPACE}
    ```

    ```bash
    # PostgreSQL alerts
    helm install prometheus-postgresql-alerts-chart oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart:{{% current_version %}} --namespace ${KUBERNETES_NAMESPACE}
    ```

## Charts

Prometheus alerts are available as Helm chart:

<!-- markdownlint-disable no-bare-urls -->
| Component | Chart URL | Website | Parameters |
| --- | --- | --- | --- |
| RDS | oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart | [Link](https://gallery.ecr.aws/qonto/prometheus-rds-alerts-chart) | [Link](https://github.com/qonto/database-monitoring-framework/blob/{{% current_version %}}/charts/prometheus-rds-alerts/values.yaml) |
| PostgreSQL | oci://public.ecr.aws/qonto/prometheus-postgresql-alerts-chart | [Link](https://gallery.ecr.aws/qonto/prometheus-postgresql-alerts-chart) | [Link](https://github.com/qonto/database-monitoring-framework/blob/{{% current_version %}}/charts/prometheus-postgresql-alerts/values.yaml)
<!-- markdownlint-enable no-bare-urls -->
