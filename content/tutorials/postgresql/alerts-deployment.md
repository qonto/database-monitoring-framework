---
title: Alerts deployment
weight: 200
---

# PostgreSQL alerts deployment

In this tutorial, you'll deploy the alerts for PostgreSQL.

## Requirements

- Helm (v3.0+)
- Kubectl (v1.25+)
- Kubernetes (v1.25+) with cluster admin permissions
- [Prometheus operator](https://github.com/prometheus-operator/prometheus-operator) (v0.61+)
- [SQL exporter](https://github.com/burningalchemist/sql_exporter) (v0.13.1+)

This tutorial assumes you have Kubernetes, Helm and Prometheus knowledge.

## Steps

1. Deploy postgresql alerts helm chart

    ```bash
    KUBERNETES_NAMESPACE=monitoring
    helm upgrade --install prometheus-postgresql-alerts-chart oci://public.ecr.aws/qonto/prometheus-postgresql-alerts-chart:{{% current_version %}} --namespace ${KUBERNETES_NAMESPACE}
    ```

1. Connect on Prometheus and check rules are defined

    ```bash
    https://<prometheus-url>/rules
    ```
