---
title: Inactive logical replication slot
---

# PostgreSQLInactiveLogicalReplicationSlot

## Meaning

Alert is triggered when a PostgreSQL logical replication slot is inactive.

## Impact

{{< postgresql-non-running-replication-slots-impacts >}}

## Diagnosis

{{< hint info >}}
Logical replication slots are used by applications for [Change Data Capture](https://www.postgresql.org/docs/current/logical-replication.html).

Example of services that may use CDC: Kafka connect, AWS DMS, ...
{{< /hint >}}

1. Prioritize. Look at the replication slot disk space consumption trend in `Replication slot available storage` panel of the  `Replication slot dashboard` to estimate the delay before reaching storage space saturation

2. Identify the non-running logical replication slot

    The `database` and `slot_name` information provide elements to identify the slot replication client.

    If the `wal_status` is `lost`, you may need to recreate the slot.

    <details>
    <summary>SQL</summary>

    {{% sql "sql/list-replication-slots.sql" %}}

    </details>

## Mitigation

The replication slot client is not consuming its replication slot. Investigate and fix the replication slot client.

## Additional resources

- <https://www.postgresql.org/docs/15/view-pg-replication-slots.html>
