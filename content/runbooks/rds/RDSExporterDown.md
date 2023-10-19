---
title: Exporter down
---

# RDSExporterDown

## Meaning

Alert is triggered when the RDS exporter can't fetch any metrics.

## Impact

The monitoring system is degraded. RDS exporter does not collect RDS metrics, alerts cannot be triggered.

## Diagnosis

Look at Prometheus RDS exporter logs. The `level=ERROR` message should explain why the exporter is failing.

Alert will automatically resolve when the exporter won't generate new errors.

## Mitigation

Fix the problem reported in the Prometheus RDS exporter error logs
