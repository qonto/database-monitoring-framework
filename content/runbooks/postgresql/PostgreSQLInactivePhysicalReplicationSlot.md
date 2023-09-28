---
title: Inactive physical replication slot
---

# PostgreSQLInactivePhysicalReplicationSlot

## Meaning

Alert is triggered when a PostgreSQL physical replication slot is inactive.

## Impact

{{< postgresql-non-running-replication-slots-impacts >}}

## Diagnosis

{{< hint info >}}
Physical replication is only used by AWS to replicate RDS instances.

A newly created RDS instance may need time to replay WAL files since the last full backup. The replication slot will not be used until the replicas have replayed all the WAL files.
{{< /hint >}}

1. Prioritize. Look at the replication slot disk space consumption trend in `Replication slot available storage` panel of the  `Replication slot dashboard` to estimate the delay before reaching storage space saturation

    <details>
    <summary>Find the RDS instance that uses the physical replication slot</summary>
    <ol>
        <li>Identify which replication slot is consuming disk space</li>
        <li>Extract the AWS RDS <i>resource_id</i> from the slot name (<i>rds_[aws_region]_db_[resource_id]</i>)</li>
        <li>Found the RDS instance in <b>RDS instances dashboard</b></li>
    </ul>
    </details>

2. Check lag of RDS replica in `RDS instance details dashboard`

3. Check replica instance logs in AWS Cloudwatch

    You may see replaying WAL file messages

## Mitigation

1. If an RDS replica instance was just created

    - If the RDS primary instance doesn't risk disk space saturation, wait until RDS initialization is finished
    - Otherwise, delete the RDS replica that owns the non-running replication slot

        Recreate the RDS replica after a full RDS snapshot and in a low activity period to limit WAL files to replay

1. Increase disk space on the primary instance

1. Open AWS support case to report non-running physical replication

## Additional resources

- <https://www.postgresql.org/docs/current/view-pg-replication-slots.html>
