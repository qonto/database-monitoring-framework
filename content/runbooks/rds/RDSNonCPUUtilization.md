---
title: Non CPU utilization
---

# RDSNonCPUUtilization

## Meaning

Alert is triggered when an RDS instance has more active queries than available vCPU.

## Impact

Performances are degraded because some queries could not be executed.

## Diagnosis

{{< hint info >}}
**Tips**

This situation usually occured when SQL queries are blocked by software reason (e.g. Locks) or hardware saturation (e.g. IOPS)
{{< /hint >}}

Identify the waits type of active queries on `RDS Performance insights`.

Select `Top waits` and `Top database` to quickly identify wait reason and database.

## Mitigation

1. If `Lock:relation`, identify and fix the lock reason

    For other wait type, looks at <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Tuning.html>

1. Kill the SQL queries

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Tuning.html>
- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.ActiveSessions.html>
