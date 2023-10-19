---
title: Disk auto scaling limit
---

# RDSDiskAutoScalingLimit

## Meaning

Alert is triggered when an RDS instance reaches its maximum disk auto-scaling limit.

## Impact

The instance's storage can no longer be increased automatically by AWS. This can lead to disk space saturation and instance shutdown.

## Diagnosis

1. Get storage auto-scaling limit

    ```bash
    aws rds describe-db-instances --db-instance-identifier <rds_instance_identifier> --query '{used: DBInstances[0].AllocatedStorage, max: DBInstances[0].MaxAllocatedStorage}'
    ```

1. Examine the disk growth trend to estimate the new limit to be applied

## Mitigation

1. Increase disk autoscaling limit (at least by 10% to allow RDS autoscaling)

    {{< hint warning >}}
{{% aws-rds-storage-increase-limitations %}}
{{< /hint >}}

    {{< hint info >}}
**AWS recommendation**

> We recommend setting it to at least 26% more to avoid receiving an event notification that the storage size is approaching the maximum storage threshold.
> [Source](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html#USER_PIOPS.Autoscaling)
{{< /hint >}}

    <!-- markdownlint-disable MD046 -->
    ```bash
    aws rds modify-db-instance \
    --db-instance-identifier  \
    --max-allocated-storage <new_storage_limit_minimum_10%_increase> \
    --apply-immediately \
    ```
    <!-- markdownlint-enable MD046 -->

1. Check that the new auto-scaling limit is applied

## Additional resources

<details>
<summary>Production experiences</summary>

- A non-functioning replication slot had blocked the WAL files rotation for some time and forced automatic disk scaling operations to its limit.

    ➡️ Monitor replication slot status

    ➡️ Don't use disk auto-scaling without RDS event notifications

</details>

{{< hint info >}}
**FinOps best practices**

You should set up and review [RDS event notifications](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-cloud-watch-events.html) for automatic disk scaling operations ([RDS-EVENT-0217](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.Messages.html#RDS-EVENT-0217)), to ensure that storage costs reflect your business activity.

{{< /hint >}}

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html>
