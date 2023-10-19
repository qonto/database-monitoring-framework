SELECT
    database,
    slot_name,
    active::TEXT,
    xmin,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS replication_lag,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS replication_lag_raw
FROM pg_replication_slots
ORDER by replication_lag_raw, database, slot_name desc;
