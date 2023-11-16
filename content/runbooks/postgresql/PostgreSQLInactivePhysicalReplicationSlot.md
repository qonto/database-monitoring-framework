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
Most of the Cloud providers use Physical replication for replicas. This is the case for AWS RDS.
{{< /hint >}}

{{< hint info >}}
A newly created RDS instance may need time to replay WAL files since the last full backup. The replication slot will not be used until the replicas have replayed all the WAL files.
{{< /hint >}}

1. **Prioritize**. Look at the replication slot disk space consumption trend in `Replication slot available storage` panel of the `Replication slot dashboard` to estimate the delay before reaching storage space saturation

    <details>
    <summary>Find the RDS instance that uses the physical replication slot</summary>
    <ol>
        <li>Identify which replication slot is consuming disk space</li>
        <li>Extract the AWS RDS <code>resource_id</code> from the slot name (<code>rds_[aws_region]_db_[resource_id]</code>)</li>
        <li>Search the RDS instance in <b>RDS instances dashboard</b></li>
    </ul>
    </details>

2. Check lag of RDS replica in `RDS instance details dashboard`

3. Check replica instance logs

    Logs of RDS instances can be seen in AWS Cloudwatch if they are exported to it.

    If the standby is replaying WAL file messages, inactivity of the Logical Replication slot is expected and should resume once all WAL files have been replayed.

## Mitigation

1. If the replica instance was just created

    - If the primary instance doesn't risk disk space saturation, wait until instance initialization is finished.

        Initialization phase can take several hours, especially on AWS RDS, as WAL replaying process is single-threaded.

    - If there is a risk of saturating disk space, delete the replica that owns the non-running replication slot.

        If you are on AWS RDS, recreate the RDS replica after a full RDS snapshot and in a low activity period to limit WAL files to replay.

        If you manage the replication, you may need to delete the physical replication slot.

2. Increase disk space on the primary instance

3. On AWS RDS, open an AWS support case to report non-running physical replication

## Additional resources

- <https://www.postgresql.org/docs/current/view-pg-replication-slots.html>
