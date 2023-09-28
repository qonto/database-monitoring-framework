---
title: Swap utilization
---

# RDSSwapUtilization

## Meaning

Alert is triggered when RDS move data on its swap.

## Impact

- Performance could be degraded

## Diagnosis

1. Check memory usage over last weeks to identify if server is missing memory

1. Check if there long running PostgreSQL clients that don't execute SQL queries for a while on `live dashboard`

    <details>
    <summary>SQL</summary>

    {{% sql "sql/list-long-running-clients.sql" %}}

    </details>

## Mitigation

1. Reduce number of concurrent connections on the server

1. Increase RDS instance type to have more memory

## Additional resources

n/a
