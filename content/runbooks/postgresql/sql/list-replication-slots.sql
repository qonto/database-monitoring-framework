SELECT
    database,
    slot_name,
    active::TEXT,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS replication_lag,
    pg_size_pretty(safe_wal_size) remaining_disk_space,
    wal_status,
    CASE
        WHEN safe_wal_size IS NOT NULL
            THEN (select (safe_wal_size / 1024 / 1024) * 100 / (setting::int) from pg_settings where name = 'max_slot_wal_keep_size')
        else
            100
    END as remaining_disk_space_percent
FROM pg_replication_slots
ORDER by remaining_disk_space_percent, database, slot_name desc;
