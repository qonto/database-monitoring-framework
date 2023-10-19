---
title: Exporter errors
---

# RDSExporterErrors

## Meaning

Alert is triggered when the Prometheus RDS exporter is reporting errors continuously.

## Impact

The monitoring system is degraded. RDS exporter does not collect RDS metrics, alerts cannot be triggered.

## Diagnosis

Look at Prometheus RDS exporter logs. The `level=ERROR` message should explain why AWS metrics can't be fetched.

Common situations:

- The exporter can't be authenticated on AWS APIs
- AWS role or AWS user used by Prometheus RDS exporter don't have required permissions

## Mitigation

Depending on the error message, fix AWS authentication/permissions and watch the number of errors.

Alert will automatically be resolved when exporter stops generating new errors.

## Additional resources

- Prometheus RDS exporter [required IAM permissions](https://github.com/qonto/prometheus-rds-exporter#aws-authentication)
