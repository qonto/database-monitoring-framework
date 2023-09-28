---
title: IOPS utilization
---

# RDSIOPSUtilization

## Meaning

Alert is triggered when RDS instance is close to its max allocated IOPS.

## Impact

Performances could be degraded.

## Diagnosis

1. Open the `RDS server` main dashboard

1. Open RDS Performance insights to identify IOPS-intensive queries

## Mitigation

1. Kill SQL queries that generate intensive IOPS

1. If specific to an application, report the issue to the application owner to improve the query

1. Increase provisioned IOPS if possible (`gp3` or `io1` storage class). Be aware that some instances [have IOPS limits](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html).

## Additional resources

n/a
