---
title: Max connections
---
# PostgreSQLMaxConnections

## Meaning

Alert is triggered when the number of connected clients is close to PostgreSQL limits.

## Impact

- Client won't be able to connect

## Diagnosis

1. Check if the number of connections per user is relevant

    <details>
    <summary>SQL</summary>

    {{% sql "sql/count-connection-per-user.sql" %}}

    Tips: Grouping by `application_name` may help to more details
    </details>

## Mitigation

1. Reduce number of clients

1. Increase `max_connections` (check memory first!)

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.MaxConnections>
