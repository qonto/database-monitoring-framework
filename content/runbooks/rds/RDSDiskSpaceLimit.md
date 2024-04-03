---
title: Disk space limit
---

# RDSDiskSpaceLimit

## Meaning

Alert is triggered when RDS instance is low on storage.

## Impact

The PostgreSQL instance will stop to prevent data corruption if no more disk space is available.

## Diagnosis

Determine whether it's a long-term growth trend requiring storage increase or abnormal disk usage reflecting another problem:

1. Check database size growth over the last 24 hours to identify abnormal disk usage growth

    Look at `Storage usage` panel in `RDS instance details` Grafana dashboard

1. Check if there are long-running transactions (or queries)

    Look at `Postgresql live activity` Grafana dashboard to find long-running query

    <details>
    <summary>Why?</summary>
    {{< postgresql-long-running-transaction-impacts >}}
    </details>

    {{< details title="PostgreSQL" open=false >}}
{{% sql "../postgresql/sql/list-long-running-transactions.sql" %}}
    {{< /details >}}

1. Check the status of PostgreSQL replication slots

    <details>
    <summary>Why?</summary>
    PostgreSQL keeps WAL files on its disk until the replication slot client acknowledges they consumed it.
    </details>

1. Check log file sizes

    <details>
    <summary>Why?</summary>
    PostgreSQL logs could consume large disk space.

    Usually related to:
    - Connection/disconnections
    - Slow queries
    - PGaudit logs
    - Internal errors
    - Temporary files

    PostgreSQL parameters:
    - `log_temp_files` can be set to log temporary file creation above a size threshold
    - `temp_file_limit` parameter can be set to avoid over-usage: <https://www.postgresql.org/docs/16/runtime-config-resource.html#RUNTIME-CONFIG-RESOURCE-DISK>
    </details>

## Mitigation

You must avoid reaching no disk space left situation.

- Fix the system that blocks PostgreSQL to recycle its WAL files

  - If long-running transactions/queries: Cancel or kill the transactions
  - If non-running replication slot: Delete replication slot

- Increase RDS disk space

    {{< hint danger >}}
{{% aws-rds-storage-increase-limitations %}}
{{< /hint >}}

    1. Set AWS_PROFILE
    
        ```bash
        export AWS_PROFILE=<AWS account>
        ```
    
    2. Determine the minimum storage for the increase
        💡 RDS requires a minimal storage increase of 10%

        ```bash
        INSTANCE_IDENTIFIER=<replace with the RDS instance identifier>
        ```

        ```bash
        aws rds describe-db-instances --db-instance-identifier ${INSTANCE_IDENTIFIER} \
        | jq -r '{"Current IOPS": .DBInstances[0].Iops, "Current Storage Limit": .DBInstances[0].AllocatedStorage, "New minimum storage size": ((.DBInstances[0].AllocatedStorage|tonumber)+(.DBInstances[0].AllocatedStorage|tonumber*0.1|floor))}'
        ```

    3. Increase storage:

        ```bash
        NEW_ALLOCATED_STORAGE=<replace with new allocated storage in GB>
        ```

        ```bash
        aws rds modify-db-instance --db-instance-identifier ${INSTANCE_IDENTIFIER} --allocated-storage ${NEW_ALLOCATED_STORAGE} --apply-immediately \
        | jq .DBInstance.PendingModifiedValues
        ```
    
        ❗ If the RDS instance has replicas instances (replica or reporting), you must repeat the operation for all replicas to keep the same configuration between instances
    
    4. Backport changes in [Terraform](https://gitlab.qonto.co/devops/terraform/stacks/rds)

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html>
- <https://docs.aws.amazon.com/cli/latest/reference/rds/modify-db-instance.html>
