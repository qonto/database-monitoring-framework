---
title: Exporter deployment
weight: 100
---

# PostgreSQL exporter deployment

In this tutorial, we'll deploy the Prometheus PostgreSQL exporter with our recommanded configuration to collect all key metrics.

## Requirements

- Helm (v3.0+)
- Kubectl (v1.25+)
- Kubernetes (v1.25+) with cluster admin permissions
- PostgreSQL admin permissions

This tutorial assumes you have some knowledge of Kubernetes, Helm and PostgreSQL.

## Steps

1. Create `prometheus_postgresql_exporter` PostgreSQL user with `pg_monitor` role

    ```sql
    CREATE ROLE prometheus_postgresql_exporter IN ROLE pg_monitor PASSWORD 'hackme' LOGIN; -- Replace with a better password
    ```

1. Create a Kubernetes secret that contain PostgreSQL exporter password

    ```bash
    KUBERNETES_NAMESPACE=monitoring
    POSTGRESQL_PASSWORD=hackme # Replace with a better password
    kubectl create secret generic postgresql-exporter-credentials --namespace ${KUBERNETES_NAMESPACE} --from-literal=password=${POSTGRESQL_PASSWORD}
    ```

1. Create `values.yaml` configuration file for PostgreSQL exporter

    ```yaml
    config:
      datasource:
        host: <replace_with_your_postgresql_host> # Replace with you PostgreSQL host
        user: prometheus_postgresql_exporter
        passwordSecret:
          key: postgresql-exporter-credentials
          name: password
    ```

1. Download customized `queries.yaml` file

    <details>
    <summary>queries.yaml</summary>

    ```yaml
    ---
    pg_replication:
    query: |
        SELECT CASE WHEN NOT pg_is_in_recovery() THEN 0 ELSE GREATEST (0, EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))) END AS lag;
    master: true
    metrics:
        - lag:
            usage: "GAUGE"
            description: "Replication lag behind master in seconds"

    pg_stat_connections:
    query: |
        SELECT state, count(*) as count from pg_stat_activity
        WHERE pid <> pg_backend_pid()
        GROUP BY 1
        ORDER BY 1;
    master: true
    metrics:
        - state:
            usage: "LABEL"
            description: "Connection status"
        - count:
            usage: "GAUGE"
            description: "Number of connections"

    pg_postmaster:
    query: |
        SELECT pg_postmaster_start_time as start_time_seconds
        FROM pg_postmaster_start_time();
    master: true
    metrics:
        - start_time_seconds:
            usage: "GAUGE"
            description: "Time at which postmaster started"

    pg_database:
    query: |
        SELECT pg_database.datname, pg_database_size(pg_database.datname) as size_bytes
        FROM pg_database
    master: true
    cache_seconds: 30
    metrics:
        - datname:
            usage: "LABEL"
            description: "Name of the database"
        - size_bytes:
            usage: "GAUGE"
            description: "Disk space used by the database"

    pg_replication_slots:
    query: |
        SELECT
            slot_name,
            database,
            active,
            slot_type,
            xmin,
            pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) as replication_lag,
            pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn) as confirmed_lag,
            CASE
                WHEN safe_wal_size IS NOT NULL
                    THEN (select (safe_wal_size / 1024 / 1024) * 100 / (setting::int) from pg_settings where name = 'max_slot_wal_keep_size')
                else
                    100
            END as available_storage_percent
        FROM pg_replication_slots;
    master: true
    metrics:
        - slot_name:
            usage: "LABEL"
            description: "Name of the replication slot"
        - database:
            usage: "LABEL"
            description: "Name of the database"
        - active:
            usage: "GAUGE"
            description: "Flag indicating if the slot is active"
        - slot_type:
            usage: "LABEL"
            description: "The slot type: physical or logical"
        - xmin:
            usage: "GAUGE"
            description: "The oldest transaction that this slot needs the database to retain. VACUUM cannot remove tuples deleted by any later transaction."
        - replication_lag:
            usage: "GAUGE"
            description: "Replication lag in bytes"
        - confirmed_lag:
            usage: "GAUGE"
            description: "Replication confirmed lag in bytes"
        - available_storage_percent:
            usage: "GAUGE"
            description: "Available storage regarding max_slot_wal_keep_size in percent"

    pg_stat_database:
    query: |
        SELECT datid, datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit, tup_returned, tup_fetched, tup_inserted, tup_updated, tup_deleted, conflicts, temp_files, temp_bytes, deadlocks, blk_read_time, blk_write_time, sessions, sessions_abandoned, stats_reset
        FROM pg_stat_database
        where datname = current_database();
    master: false  # This query need to be executed per database to avoid abnormal metrics in staging
    metrics:
        - datid:
            usage: LABEL
            description: "OID of a database"
        - datname:
            usage: LABEL
            description: "Name of this database"
        - numbackends:
            usage: GAUGE
            description: "Number of backends currently connected to this database. This is the only column in this view that returns a value reflecting current state; all other columns return the accumulated values since the last reset."
        - xact_commit:
            usage: COUNTER
            description: "Number of transactions in this database that have been committed"
        - xact_rollback:
            usage: COUNTER
            description: "Number of transactions in this database that have been rolled back"
        - blks_read:
            usage: COUNTER
            description: "Number of disk blocks read in this database"
        - blks_hit:
            usage: COUNTER
            description: "Number of times disk blocks were found already in the buffer cache, so that a read was not necessary (this only includes hits in the PostgreSQL buffer cache, not the operating system's file system cache)"
        - tup_returned:
            usage: COUNTER
            description: "Number of rows returned by queries in this database"
        - tup_fetched:
            usage: COUNTER
            description: "Number of rows fetched by queries in this database"
        - tup_inserted:
            usage: COUNTER
            description: "Number of rows inserted by queries in this database"
        - tup_updated:
            usage: COUNTER
            description: "Number of rows updated by queries in this database"
        - tup_deleted:
            usage: COUNTER
            description: "Number of rows deleted by queries in this database"
        - conflicts:
            usage: COUNTER
            description: "Number of queries canceled due to conflicts with recovery in this database. (Conflicts occur only on standby servers; see pg_stat_database_conflicts for details.)"
        - temp_files:
            usage: COUNTER
            description: "Number of temporary files created by queries in this database. All temporary files are counted, regardless of why the temporary file was created (e.g., sorting or hashing), and regardless of the log_temp_files setting."
        - temp_bytes:
            usage: COUNTER
            description: "Total amount of data written to temporary files by queries in this database. All temporary files are counted, regardless of why the temporary file was created, and regardless of the log_temp_files setting."
        - deadlocks:
            usage: COUNTER
            description: "Number of deadlocks detected in this database"
        - blk_read_time:
            usage: COUNTER
            description: "Time spent reading data file blocks by backends in this database, in milliseconds"
        - blk_write_time:
            usage: COUNTER
            description: "Time spent writing data file blocks by backends in this database, in milliseconds"
        - stats_reset:
            usage: COUNTER
            description: "Time at which these statistics were last reset"
        - sessions:
            usage: COUNTER
            description: "Total number of sessions established to this database"
        - sessions_abandoned:
            usage: COUNTER
            description: "Number of database sessions to this database that were terminated because connection to the client was lost"

    pg_stat_user_tables:
    query: |
        SELECT
        current_database() datname,
        u.schemaname,
        u.relname,
        u.seq_scan,
        u.seq_tup_read,
        u.idx_scan,
        u.idx_tup_fetch,
        u.n_tup_ins,
        u.n_tup_upd,
        u.n_tup_del,
        u.n_tup_hot_upd,
        u.n_live_tup,
        u.n_dead_tup,
        u.n_mod_since_analyze,
        COALESCE(u.last_vacuum, '1970-01-01Z') as last_vacuum,
        COALESCE(u.last_autovacuum, '1970-01-01Z') as last_autovacuum,
        COALESCE(u.last_analyze, '1970-01-01Z') as last_analyze,
        COALESCE(u.last_autoanalyze, '1970-01-01Z') as last_autoanalyze,
        u.vacuum_count,
        u.autovacuum_count,
        u.analyze_count,
        u.autoanalyze_count,
        table_size + index_size AS total_bytes,
        index_size AS index_bytes,
        toast_size AS toast_bytes,
        table_size - coalesce(toast_size,0) AS table_bytes
        FROM
        pg_stat_user_tables u JOIN
        (
            SELECT
            pg_class.oid,
            pg_table_size(pg_class.oid)                    AS table_size,
            pg_indexes_size(pg_class.oid)                  AS index_size,
            pg_total_relation_size(pg_class.reltoastrelid) AS toast_size
            FROM
            pg_stat_user_tables u
            JOIN pg_class ON pg_class.oid = u.relid AND pg_class.relkind <> 'm' -- exclude matviews to prevent query being locked when refreshing MV
        UNION ALL
            SELECT
            c.oid,
            SUM(c.relpages::bigint*8192) AS table_size,
            coalesce(SUM(idx.index_bytes),0) as index_size,
            coalesce(SUM((c2.relpages+c3.relpages)::bigint*8192),0) AS toast_size
            FROM pg_stat_user_tables u
            JOIN pg_class c ON u.relid=c.oid AND c.relkind='m'   -- matviews only
            LEFT JOIN pg_class c2 ON c2.oid = c.reltoastrelid
            LEFT JOIN pg_index it ON it.indrelid=c.reltoastrelid  -- only one index per pg_toast table
            LEFT JOIN pg_class c3 ON c3.oid=it.indexrelid
            CROSS JOIN LATERAL (
                SELECT SUM(c4.relpages::bigint*8192) AS index_bytes
                FROM pg_index i JOIN pg_class c4 ON i.indrelid=c.oid AND c4.oid=i.indexrelid
            ) idx
            GROUP BY c.oid
        ) t ON u.relid = t.oid
        ;
    metrics:
        - datname:
            usage: "LABEL"
            description: "Name of current database"
        - schemaname:
            usage: "LABEL"
            description: "Name of the schema that this table is in"
        - relname:
            usage: "LABEL"
            description: "Name of this table"
        - seq_scan:
            usage: "COUNTER"
            description: "Number of sequential scans initiated on this table"
        - seq_tup_read:
            usage: "COUNTER"
            description: "Number of live rows fetched by sequential scans"
        - idx_scan:
            usage: "COUNTER"
            description: "Number of index scans initiated on this table"
        - idx_tup_fetch:
            usage: "COUNTER"
            description: "Number of live rows fetched by index scans"
        - n_tup_ins:
            usage: "COUNTER"
            description: "Number of rows inserted"
        - n_tup_upd:
            usage: "COUNTER"
            description: "Number of rows updated"
        - n_tup_del:
            usage: "COUNTER"
            description: "Number of rows deleted"
        - n_tup_hot_upd:
            usage: "COUNTER"
            description: "Number of rows HOT updated (i.e., with no separate index update required)"
        - n_live_tup:
            usage: "GAUGE"
            description: "Estimated number of live rows"
        - n_dead_tup:
            usage: "GAUGE"
            description: "Estimated number of dead rows"
        - n_mod_since_analyze:
            usage: "GAUGE"
            description: "Estimated number of rows changed since last analyze"
        - last_vacuum:
            usage: "GAUGE"
            description: "Last time at which this table was manually vacuumed (not counting VACUUM FULL)"
        - last_autovacuum:
            usage: "GAUGE"
            description: "Last time at which this table was vacuumed by the autovacuum daemon"
        - last_analyze:
            usage: "GAUGE"
            description: "Last time at which this table was manually analyzed"
        - last_autoanalyze:
            usage: "GAUGE"
            description: "Last time at which this table was analyzed by the autovacuum daemon"
        - vacuum_count:
            usage: "COUNTER"
            description: "Number of times this table has been manually vacuumed (not counting VACUUM FULL)"
        - autovacuum_count:
            usage: "COUNTER"
            description: "Number of times this table has been vacuumed by the autovacuum daemon"
        - analyze_count:
            usage: "COUNTER"
            description: "Number of times this table has been manually analyzed"
        - autoanalyze_count:
            usage: "COUNTER"
            description: "Number of times this table has been analyzed by the autovacuum daemon"
        - total_bytes:
            usage: "GAUGE"
            description: "Total disk space used by the specified table, including all indexes and TOAST data"
        - index_bytes:
            usage: "GAUGE"
            description: "Total disk space used by indexes attached to the specified table"
        - toast_bytes:
            usage: "GAUGE"
            description: "Total disk space used by TOAST data"
        - table_bytes:
            usage: "GAUGE"
            description: "Total disk space used by the specified table, excluding indexes and TOAST data"

    pg_locks:
    master: false  # This query need to be executed per database to avoid abnormal metrics in staging
    query: |
        SELECT pg_database.datname,tmp.mode,COALESCE(count,0) as count
        FROM
        (
            VALUES ('accesssharelock'),
            ('rowsharelock'),
            ('rowexclusivelock'),
            ('shareupdateexclusivelock'),
            ('sharelock'),
            ('sharerowexclusivelock'),
            ('exclusivelock'),
            ('accessexclusivelock'),
            ('sireadlock')
        ) AS tmp(mode) CROSS JOIN pg_database
        LEFT JOIN
        (
            SELECT database, lower(mode) AS mode,count(*) AS count
            FROM pg_locks WHERE database IS NOT NULL
            GROUP BY database, lower(mode)
        ) AS tmp2
        ON tmp.mode=tmp2.mode and pg_database.oid = tmp2.database
        WHERE pg_database.datname = current_database()
        ORDER BY 1
    metrics:
        - datname:
            usage: "LABEL"
            description: "Name of current database"
        - mode:
            usage: "LABEL"
            description: "Name of the lock mode"
        - count:
            usage: "GAUGE"
            description: "Number of locks held by open transactions"

    pg_statio_user_tables:
    query: |
        SELECT current_database() datname, schemaname, relname, heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit, toast_blks_read, toast_blks_hit, tidx_blks_read, tidx_blks_hit
        FROM pg_statio_user_tables;
    metrics:
        - datname:
            usage: "LABEL"
            description: "Name of current database"
        - schemaname:
            usage: "LABEL"
            description: "Name of the schema that this table is in"
        - relname:
            usage: "LABEL"
            description: "Name of this table"
        - heap_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from this table"
        - heap_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in this table"
        - idx_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from all indexes on this table"
        - idx_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in all indexes on this table"
        - toast_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from this table's TOAST table (if any)"
        - toast_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in this table's TOAST table (if any)"
        - tidx_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from this table's TOAST table indexes (if any)"
        - tidx_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in this table's TOAST table indexes (if any)"

    pg_stat_progress_vacuum:
    query: |
        SELECT
        s.pid,
        s.datname,
        s.relid,
        s.relid::regclass as relname,
        extract(epoch from now() - xact_start) as duration,
        CASE s.phase WHEN 'initializing' THEN 0
            WHEN 'scanning heap' THEN 1
            WHEN 'vacuuming indexes' THEN 2
            WHEN 'vacuuming heap' THEN 3
            WHEN 'cleaning up indexes' THEN 4
            WHEN 'truncating heap' THEN 5
            WHEN 'performing final cleanup' THEN 6
            END AS phase,
        CASE
            WHEN a.query ~*'^autovacuum.*to prevent wraparound' THEN 2
            WHEN a.query ~*'^vacuum' THEN 1
            ELSE 0
            END AS mode,
        s.heap_blks_total,
        s.heap_blks_scanned,
        s.heap_blks_vacuumed,
        s.index_vacuum_count,
        s.max_dead_tuples,
        s.num_dead_tuples
        FROM pg_stat_progress_vacuum as s
        JOIN pg_stat_activity AS a USING ( pid )
        where S.datname = current_database();
    master: false  # This query need to be executed per database to resolve relname (relid::regclass)
    metrics:
        - pid:
            usage: GAUGE
            description: Process ID of backend
        - datname:
            usage: LABEL
            description: Name of the database to which this backend is connected
        - relname:
            usage: LABEL
            description: Name of the table
        - duration:
            usage: GAUGE
            description: Vacuum duration in seconds
        - relid:
            usage: LABEL
            description: OID of the resource
        - phase:
            usage: GAUGE
            description: Phase
        - mode:
            usage: GAUGE
            description: "Vacuum mode (0: autovacuum, 1: user, 2: prevent wraparound)"
        - heap_blks_total:
            usage: GAUGE
            description: Total number of heap blocks in the table
        - heap_blks_scanned:
            usage: GAUGE
            description: Number of heap blocks scanned
        - heap_blks_vacuumed:
            usage: GAUGE
            description: Number of heap blocks vacuumed
        - index_vacuum_count:
            usage: GAUGE
            description: Number of completed index vacuum cycles
        - max_dead_tuples:
            usage: GAUGE
            description: Number of dead tuples that we can store before needing to perform an index vacuum cycle.
        - num_dead_tuples:
            usage: GAUGE
            description: Number of dead tuples collected since the last index vacuum cycle.

    pg_stat_replication_slots:
    query: |
        SELECT slot_name, spill_txns, spill_count, spill_bytes, total_txns, total_bytes
        FROM pg_stat_replication_slots;
    master: true
    metrics:
        - slot_name:
            usage: LABEL
            description: "A unique, cluster-wide identifier for the replication slot"
        - spill_txns:
            usage: COUNTER
            description: "Number of transactions spilled to disk once the memory used by logical decoding to decode changes from WAL has exceeded logical_decoding_work_mem. The counter gets incremented for both top-level transactions and subtransactions"
        - spill_count:
            usage: COUNTER
            description: "Number of times transactions were spilled to disk while decoding changes from WAL for this slot. This counter is incremented each time a transaction is spilled, and the same transaction may be spilled multiple times"
        - spill_bytes:
            usage: COUNTER
            description: "Amount of decoded transaction data spilled to disk while performing decoding of changes from WAL for this slot. This and other spill counters can be used to gauge the I/O which occurred during logical decoding and allow tuning logical_decoding_work_mem."
        - total_txns:
            usage: COUNTER
            description: "Number of decoded transactions sent to the decoding output plugin for this slot. This counts top-level transactions only, and is not incremented for subtransactions. Note that this includes the transactions that are streamed and/or spilled."
        - total_bytes:
            usage: COUNTER
            description: "Amount of transaction data decoded for sending transactions to the decoding output plugin while decoding changes from WAL for this slot. Note that this includes data that is streamed and/or spilled"

    pg_stat_user_indexes:
    query: |
        SELECT current_database() datname, us.schemaname, us.relname, us.indexrelname, us.idx_scan, us.idx_tup_read, us.idx_tup_fetch, io.idx_blks_read, io.idx_blks_hit, ind.indisvalid
        FROM pg_index as ind, pg_stat_user_indexes as us, pg_statio_user_indexes as io
        WHERE ind.indexrelid = us.indexrelid
        AND ind.indexrelid = io.indexrelid;
    master: false  # This query need to be executed per database to resolve relname (relid::regclass)
    metrics:
        - datname:
            usage: "LABEL"
            description: "Name of current database"
        - schemaname:
            usage: "LABEL"
            description: "Name of the schema that this table is in"
        - relname:
            usage: "LABEL"
            description: "Name of this table"
        - indexrelname:
            usage: "LABEL"
            description: "Name of this index"
        - idx_scan:
            usage: "COUNTER"
            description: "Number of index scans initiated on this index"
        - idx_tup_read:
            usage: "COUNTER"
            description: "Number of index entries returned by scans on this index"
        - idx_tup_fetch:
            usage: "COUNTER"
            description: "Number of live table rows fetched by simple index scans using this index"
        - idx_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from this index"
        - idx_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in this index"
        - indisvalid:
            usage: "LABEL"
            description: "If true, the index is currently valid for queries. False means the index is possibly incomplete: it must still be modified by INSERT/UPDATE operations, but it cannot safely be used for queries"

    # Collect pid, usename and datname information of long running queries
    pg_active_backend:
    query: |
        SELECT
            pid,
            usename,
            datname,
            EXTRACT('minutes' FROM  now() - state_change) AS duration_minutes
        FROM
            pg_stat_activity
        WHERE
            state = 'active'
            AND backend_type != 'walsender'
            AND EXTRACT('minutes' FROM  now() - state_change) > 5;
    master: true
    metrics:
        - usename:
            usage: "LABEL"
            description: "PostgreSQL username"
        - datname:
            usage: "LABEL"
            description: "PostgreSQL database"
        - pid:
            usage: "LABEL"
            description: "Backend pid"
        - duration_minutes:
            usage: "GAUGE"
            description: "Query duration"

    pg_statio_all_tables:
    query: |
        SELECT
            relid,
            current_database() datname,
            schemaname,
            relname,
            heap_blks_read,
            heap_blks_hit,
            idx_blks_read,
            idx_blks_hit
        FROM
            pg_statio_all_tables
        WHERE
            current_database() in ('qonto_api', 'qonto_auth', 'qonto_biller', 'qonto_fraud')
            AND schemaname not in ('pg_catalog', 'pg_toast', 'information_schema')
            AND relname not like 'sca_sessions_partitions_%'
    master: false # This query need to be executed per database to have the metric
    metrics:
        - relid:
            usage: LABEL
            description: OID of the resource
        - schemaname:
            usage: "LABEL"
            description: "Name of the schema that this table is in"
        - relname:
            usage: "LABEL"
            description: "Name of this table"
        - datname:
            usage: "LABEL"
            description: "Name of the database"
        - heap_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from this table"
        - heap_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in this table"
        - idx_blks_read:
            usage: "COUNTER"
            description: "Number of disk blocks read from all indexes on this table"
        - idx_blks_hit:
            usage: "COUNTER"
            description: "Number of buffer hits in all indexes on this table"
    ```

    </details>

1. Deploy PostgreSQL exporter using [prometheus-postgres-exporter helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-postgres-exporter)

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm upgrade --install prometheus-postgres-exporter prometheus-community/prometheus-postgres-exporter --namespace ${KUBERNETES_NAMESPACE} --values values.yaml --set-file config.queries=queries.yaml
    ```
