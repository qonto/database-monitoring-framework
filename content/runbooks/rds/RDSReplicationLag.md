---
title: Replication lag
---

# RDSReplicationLag

## Meaning

Alert is triggered when an RDS instance has unacceptable replication lag.

## Impact

- Applications that rely on up-to-date data may not work properly

## Diagnosis

1. Check IOPS saturation on the RDS instance

    If IOPS are saturated, replication could have difficulties to be applied

1. Check if a long-running transactions is executed on the replica instance

    {{< tabs "long-running-transactions" >}}
    {{< tab "PostgreSQL" >}}

Long-running transactions on a PostgreSQL replica could block the data replication process.

<details>
<summary>SQL</summary>

{{% sql "../postgresql/sql/list-long-running-transactions.sql" %}}
</details>

    {{< /tab >}}
    {{< /tabs >}}

## Mitigation

1. Kill long-running queries on replica

1. Increase IOPS if they are saturated

## Additional resources

n/a
