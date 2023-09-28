SELECT pid, usename, datname, application_name, now() - query_start duration, left(query, 60)
FROM   pg_stat_activity
WHERE  state = 'active'
    AND    wait_event_type IS NULL
    AND    wait_event IS NULL
ORDER BY duration desc;
