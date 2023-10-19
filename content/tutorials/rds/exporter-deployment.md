---
title: Exporter deployment
weight: 100
---

# RDS exporter deployment

In this tutorial, we'll deploy the Prometheus RDS exporter and import Grafana dashboards.

Depending of your technical environment, you choose between:

- AWS role with IRSA (recommended for AWS EKS users)

- AWS IAM user with API credentials

## Requirements

- [AWS cli](https://aws.amazon.com/cli/) (v2.0+) with `AdministratorAccess` IAM role
- Helm (v3.0+)
- Kubectl (v1.25+)
- Kubernetes (v1.25+) with cluster admin permissions
- [Prometheus operator](https://github.com/prometheus-operator/prometheus-operator) (v0.61+)

This tutorial assumes you have some knowledge of Kubernetes, Helm and AWS IAM.

## Steps

1. Deploy [Prometheus RDS exporter](https://github.com/qonto/prometheus-rds-exporter)

    {{< tabs "rds_alerts_installation" >}}
{{< tab "AWS role with IRSA (recommended)" >}}
**Requirements:**

- AWS EKS cluster
- eksctl

<!-- markdownlint-disable-next-line no-emphasis-as-header -->
**Steps**

1. Create an IAM policy

    The IAM policy will be used by the Prometheus RDS exporter to fetch metrics from AWS APIs.

    ```bash
    IAM_POLICY_NAME=prometheus-rds-exporter
    curl https://raw.githubusercontent.com/qonto/prometheus-rds-exporter/0.1.0/configs/aws/policy.json > policy.json
    aws iam create-policy --policy-name ${IAM_POLICY_NAME} --policy-document file://policy.json
    ```

1. Create IAM role and Kubernetes Service Account

    The Kubernetes Service Account will be used by the Kubernetes pod executing the Prometheus RDS exporter to assume to IAM policy created at the previous step.

    ```bash
    EKS_CLUSTER_NAME=default # Replace with your EKS cluster name
    KUBERNETES_NAMESPACE=default # Replace with the namespace that you want to use
    IAM_ROLE_NAME=prometheus-rds-exporter
    KUBERNETES_SERVICE_ACCOUNT_NAME=prometheus-rds-exporter
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
    eksctl create iamserviceaccount --cluster ${EKS_CLUSTER_NAME} --namespace ${KUBERNETES_NAMESPACE} --name ${KUBERNETES_SERVICE_ACCOUNT_NAME} --role-name ${IAM_ROLE_NAME} --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${IAM_POLICY_NAME} --approve
    ```

1. Deploy Prometheus RDS exporter

    ```bash
    helm install prometheus-rds-alerts-chart oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart --namespace ${KUBERNETES_NAMESPACE} --set serviceAccount.annotations."eks\.amazonaws\.com\/role-arn"="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IAM_ROLE_NAME}"
    ```

{{< /tab >}}
{{< tab "AWS IAM user" >}}
**Steps:**

1. Create AWS IAM user with IAM credentials

    ```bash
    IAM_USER_NAME=qa-documentation
    aws iam create-user --user-name ${IAM_USER_NAME}
    aws iam create-access-key --user-name ${IAM_USER_NAME}
    ```

1. Create IAM policy and attach it to the IAM user

    ```bash
    IAM_POLICY_NAME=prometheus-rds-exporter
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
    curl https://raw.githubusercontent.com/qonto/prometheus-rds-exporter/0.1.0/configs/aws/policy.json > policy.json
    aws iam create-policy --policy-name ${IAM_POLICY_NAME} --policy-document file://policy.json
    aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${IAM_POLICY_NAME}
    ```

1. Create Kubernetes secret with IAM credentials

    ```bash
    KUBERNETES_NAMESPACE=default # Replace with the namespace that you want to use
    KUBERNETES_SECRET_NAME=prometheus-rds-exporter-credentials
    kubectl create secret generic ${KUBERNETES_SECRET_NAME} --namespace ${KUBERNETES_NAMESPACE} --from-literal=AWS_ACCESS_KEY_ID=<replace_with_the_access_key_id> --from-literal=AWS_SECRET_ACCESS_KEY=<replace_with_the_secret_access_key>
    ```

1. Deploy the RDS exporter

    ```bash
    helm install prometheus-rds-alerts-chart oci://public.ecr.aws/qonto/prometheus-rds-alerts-chart --namespace ${KUBERNETES_NAMESPACE} --set awsCredentialsSecret="${KUBERNETES_SECRET_NAME}"
    ```

{{< /tab >}}
{{< /tabs >}}

1. Check exporter's metrics are collected by Prometheus

    Connect on your Prometheus web server and search for the `up{}` metric exposed by the RDS exporter.

    Metrics is `1` when RDS exporter can fetch RDS metrics.

    ```bash
    https://<your-prometheus-url>/graph?g0.expr=up%20*%20on%20(instance)%20rds_exporter_build_info&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h
    ```

1. Import the public Grafana dashboards for the RDS exporter

    | Dashboard ID | Title | Description |
    | --- | --- | --- |
    | [19647](https://grafana.com/grafana/dashboards/19647-rds-instances-overview/) | RDS instances | Inventory of RDS instances |
    | [19646](https://grafana.com/grafana/dashboards/19646-rds-instance-details/) | RDS instance details | AWS RDS instance details |
    | [19679](https://grafana.com/grafana/dashboards/19679-rds-exporter/) | Prometheus RDS exporter | Prometheus RDS exporter metrics |

    <details>
    <summary>How to import a public dashboard in Grafana?</summary>

    1. Connect to your Grafana

    1. Click on `Import dashboard` (top right corner)

    1. Enter `Grafana dashboard id` in `Import via grafana.com` and click on `Load`

    1. Select a `Folder` to store the dashboard

        We recommend that you leave the dashboard name unchanged to facilitate future updates.

    1. Click on `Save`

    </details>

1. Finally open the `RDS instances` dashboard to see the metrics

# Additional resources

- <https://support.coreos.com/hc/en-us/articles/360000155514-Prometheus-ServiceMonitor-troubleshooting>
