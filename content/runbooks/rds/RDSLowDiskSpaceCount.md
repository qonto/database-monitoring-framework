---
title: Free disk space is under 20 percent for at least one instance
---

# RDSLowDiskSpaceCount

## Meaning

Alert is triggered when at least one RDS instance is under the threshold on storage left.

## Impact

The PostgreSQL instance(s) might stop to prevent data corruption if no more disk space is available.

## Diagnosis

1. Find affected instance list in prometheus with:

   ```promql
   max by (aws_account_id, aws_region, dbidentifier) (rds_free_storage_bytes{} * 100 / rds_allocated_storage_bytes{}) < 20
   ```

1. Refer to [RDSDiskSpaceLimit](RDSDiskSpaceLimit.md) for each of them as it's the same alert just ringing a bit earlier.
