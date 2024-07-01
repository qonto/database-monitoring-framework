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

{{< tabs "methods" >}}
{{< tab "Prometheus Kubernetes Operator" >}}
Requirements

- [Helm](https://helm.sh/docs/intro/install/)

- [Prometheus Kubernetes operator](https://github.com/prometheus-operator/prometheus-operator)

    1. `ruleSelector` must be enabled ([documentation](https://github.com/prometheus-operator/prometheus-operator/blob/v0.68.0/Documentation/user-guides/alerting.md#deploying-prometheus-rules))

    1. `serviceMonitorSelector` must be enabled for `ServiceMonitor` ([documentation](https://github.com/prometheus-operator/prometheus-operator/blob/v0.68.0/Documentation/user-guides/alerting.md#deploying-prometheus-rules))

Steps

1. Deploy [Prometheus RDS exporter]({{< ref "/tutorials/rds/exporter-deployment" >}}) and/or [Prometheus PostgreSQL exporter]({{< ref "/tutorials/postgresql/exporter-deployment" >}})

1. Deploy charts with helm

    ```bash
    # RDS alerts
    helm install prometheus-rds-alerts-chart oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart \
    --version {{% current_version %}} \
    --namespace monitoring
    ```

    ```bash
    # PostgreSQL alerts
    helm install prometheus-postgresql-alerts-chart oci://public.ecr.aws/qonto/prometheus-postgresql-alerts-chart \
    --version {{% current_version %}} \
    --namespace monitoring
    ```

1. Connect to Prometheus to check that the rules are correctly loaded (`https://<your_prometheus_url>/rules`)

{{< /tab >}}
{{< tab "Prometheus standalone server" >}}

Requirements

- [Helm](https://helm.sh/docs/intro/install/)

- [Prometheus server](https://prometheus.io/docs/prometheus/latest/installation/)

Steps

1. Deploy [Prometheus RDS exporter]({{< ref "/tutorials/rds/exporter-deployment" >}}) and/or [Prometheus PostgreSQL exporter]({{< ref "/tutorials/postgresql/exporter-deployment" >}})

1. Generate Prometheus rule configuration files

    ```bash
    # Generate RDS rules in /etc/prometheus/rds.rules.yaml
    helm template oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart \
    --version {{% current_version %}} \
    --set format=PrometheusConfigurationFile \
    > /etc/prometheus/rds.rules.yaml
    ```

    ```bash
    # Generate PostgreSQL rules in /etc/prometheus/postgresql.rules.yaml
    helm template oci://public.ecr.aws/qonto/prometheus-postgresql-alerts-chart \
    --version {{% current_version %}} \
    --set format=PrometheusConfigurationFile \
    > /etc/postgresql.rules.yaml
    ```

1. Add files to the `rule_files` parameter in the Prometheus configuration file

    ```yaml
    rule_files:
      - /etc/prometheus/rds.rules.yaml
      - /etc/prometheus/postgresql.rules.yaml
    ```

1. Reload Prometheus configuration

1. Connect to Prometheus to check that the rules are correctly loaded (`https://<your_prometheus_url>/rules`)

{{< /tab >}}
{{< /tabs >}}

## Charts

Prometheus alerts are available as Helm chart:

<!-- markdownlint-disable no-bare-urls -->

| Component | Chart URL | Website | Parameters |
| --- | --- | --- | --- |
| RDS | oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart | [Link](https://gallery.ecr.aws/qonto/prometheus-rds-alerts-chart) | [Link](https://github.com/qonto/database-monitoring-framework/blob/{{% current_version %}}/charts/prometheus-rds-alerts/values.yaml) |
| PostgreSQL | oci://public.ecr.aws/qonto/prometheus-postgresql-alerts-chart | [Link](https://gallery.ecr.aws/qonto/prometheus-postgresql-alerts-chart) | [Link](https://github.com/qonto/database-monitoring-framework/blob/{{% current_version %}}/charts/prometheus-postgresql-alerts/values.yaml) |

<!-- markdownlint-enable no-bare-urls -->
