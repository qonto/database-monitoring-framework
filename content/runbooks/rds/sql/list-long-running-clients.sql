SELECT
    pid,
    usename,
    datname,
    application_name,
    age(now(), query_start) as last_query_age,
    age(now(), backend_start) as backend_age,
    backend_start,
    query_start last_query,
    left(query, 60) query
FROM pg_stat_activity
WHERE query_start is not null
    AND pid != pg_backend_pid()
    AND usename != 'rdsrepladmin'
    AND state != 'active'
    AND query not like 'START_REPLICATION %'
    AND query_start < NOW() - INTERVAL '24 HOURS'
ORDER by query_start asc;
