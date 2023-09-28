---
title: Introduction
type: docs
enableGitInfo: true
---

Welcome to the Database Monitoring Framework for *PostgreSQL* and *AWS RDS*.

Framework is meticulously crafted by a team of Site Reliability Engineers managing RDS and PostgreSQL production systems. It's open to contributions, see [contributing]({{< relref "contributing.md" >}}).

## Vision

In the container and cloud-first era, many companies are now using the same technical stacks (Kubernetes, PostgreSQL, and Prometheus). Engineers must identify relevant metrics, develop homemade systems to collect these metrics, create dashboards, define alerts, and write runbooks. It could take years to achieve optimal configuration.

This project aims to share meaningful alerts and runbooks for AWS RDS and PostgreSQL that all production systems should use.

## How?

Database Monitoring Framework provides:

- Relevant Prometheus alerts
- Customizable Helm chart to deploy alerts
- Runbooks

You can deploy and customized the framework, see [getting started page]({{< relref "getting-started.md" >}}).
