SELECT
    usename,
    count(*) AS total
FROM
    pg_stat_activity
GROUP BY
    usename
ORDER BY
    total DESC
LIMIT 100;
