---
title: Forced maintenance
---

# RDSForcedMaintenance

## Meaning

Alert is triggered when an AWS RDS maintenance operation will be forced by AWS.

## Impact

- AWS RDS maintenance will be applied on next maintenance window

    Instance will be unavailable during maintenance if multi-AZ is not enabled.

## Diagnosis

1. Check if multi-AZ is enabled to measure downtime impact

1. Check if RDS maintenance windows is relevant

## Mitigation

Adjust maintenance windows to match non business hours ([AWS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#AdjustingTheMaintenanceWindow)) or apply maintenance manually ([AWS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#USER_UpgradeDBInstance.OSUpgrades)).

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Concepts.DBMaintenance>
- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html#Concepts.MultiAZ.Migrating>
