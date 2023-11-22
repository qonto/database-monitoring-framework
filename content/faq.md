---
title: FAQ
weight: 500
---

# FAQ

## Project

### What is this project?

This project was initiated by [Qonto's](https://qonto.com/) SRE engineers to share and improve database monitoring systems.

## Is there similar intiatives?

Yes, we took lots of inspiration on [Prometheus-operator runbook](https://github.com/prometheus-operator/runbooks), which provides similar experience for Prometheus & Kubernetes technologies.

## Deployment

### Can I deploy the database monitoring framework on Prometheus standalone deployment?

Project was designed for Kubernetes deployment using Prometheus operator, but you can use for standalone deployment.

Use the `format=PrometheusConfigurationFile` Helm parameter to render rules as Prometheus rule files.

## Alerts

### Customize alerts

All alerts can be customized by overriding `rules` in [Helm chart values](https://helm.sh/docs/chart_template_guide/values_files/).

Example to override priority `severity` for `RDSExporterErrors` alert of RDS exporter alerts:

1. Create a `custom_values.yaml` file with your overrided settings

    ```yaml
    # custom_values.yaml
    rules:
      RDSExporterErrors:
        severity: critical # Override priority for RDSExporterErrors alert
    ```

1. Install (or update) deployment with overridden values

    ```yaml
    helm upgrade --install prometheus-rds-alerts-chart oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart:{{% current_version %}} --values custom_values.yaml
    ```

### Disable an alert

If an alert is not relevant for your environment, you can disable using `enabled`

```yaml
rules:
  RDSCPUUtilization:
    enabled: false
```

### Pint comments

If you are using [Pint](https://cloudflare.github.io/pint/) as Prometheus rule linter/validator, you can add pint comments to alert using the `pintComments` parameter.

{{< hint info >}}
**Recommendation**

Pint ignore comments should be set only on alerts that are relevant for your environment otherwise you should disable the rule.
{{< /hint >}}

Example to add `pint disable promql/series` on `PostgreSQLInvalidIndex` rule:

```yaml
rules:
  PostgreSQLInvalidIndex:
    pintComments:
      - disable promql/series
```

Will be render as:

```yaml
...
- alert: "PostgreSQLInvalidIndex"
  # pint disable promql/series
  expr: |
    ...
```
