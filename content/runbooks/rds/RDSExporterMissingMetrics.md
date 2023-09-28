---
title: Exporter missing metrics
---

# RDSExporterMissingMetrics

## Meaning

Alert is triggered when Prometheus doesn't have any metrics for the Prometheus RDS exporter.

## Impact

Monitoring system is degraded. The Prometheus don't collect RDS metrics, RDS alerts won't work.

## Diagnosis

1. Check Prometheus RDS exporter is in Prometheus scrape targets (see `https://<prometheus-url>/targets`)

1. Check Prometheus RDS exporter logs

## Mitigation

Make sure Prometheus can scrape the Prometheus RDS exporter

## Additional resources

n/a
