---
title: Replication slot storage limit
---

# PostgreSQLReplicationSlotStorageLimit

## Meaning

Alert is triggered when a PostgreSQL replication slot is close to the maximum size it can use on disk.

## Impact

{{< postgresql-non-running-replication-slots-impacts >}}

<details>
<summary>More</summary>

The `max_slot_wal_keep_size` parameter specifies the maximum size of WAL files that replication slots can retain in the `pg_wal` directory at checkpoint time.

If `restart_lsn` of a replication slot falls behind the current LSN by more than the given size, the standby using the slot may no longer be able to continue replication due to removal of required WAL files
</details>

## Diagnosis

- Check the replication slot status in `Replication slot dashboard`

    <details>
    <summary>SQL</summary>

    {{% sql "sql/list-replication-slots.sql" %}}

    </details>

- Check replication slot client logs and performances

    If the replication slot client is not running or performing correctly, it may have difficulties to consume the replication slot

## Mitigation

- Correct the root cause on replication slot client

- Increase `max_slot_wal_keep_size` to allow more disk space for the replication slot (check free storage first!)

- Increase server storage

## Additional resources

- <https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-MAX-SLOT-WAL-KEEP-SIZE>
