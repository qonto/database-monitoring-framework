SELECT
    pid,
    leader_pid,
    datname as database,
    usename AS user,
    application_name,
    EXTRACT(EPOCH FROM now() - xact_start) as transaction_duration,
    CASE
        WHEN state = 'active' THEN EXTRACT(EPOCH FROM now() - query_start)
        ELSE null
    END query_duration,
    state,
    wait_event_type,
    wait_event,
    CASE
        WHEN state = 'active' THEN query
        ELSE null
    END query,
    xact_start as transaction_start,
    CASE
        WHEN state = 'active' THEN query_start
        ELSE null
    END query_start,
    CASE
        WHEN state != 'active' THEN EXTRACT(EPOCH FROM state_change - query_start)
        ELSE null
    END last_query_duration,
    CASE
        WHEN state != 'active' THEN query
        ELSE null
    END last_query,
    pg_blocking_pids(pid) as blocked_by,
    client_addr,
    backend_start,
    ceil(EXTRACT(EPOCH FROM now() - backend_start)) as backend_duration
FROM pg_stat_activity
WHERE query_start is not null
    AND usename!='rdsrepladmin'
    AND query not like 'START_REPLICATION %'
    AND pid != pg_backend_pid();
