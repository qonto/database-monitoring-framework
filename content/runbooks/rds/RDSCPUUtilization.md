---
title: CPU utilization
---

# RDSCPUUtilization

## Meaning

This alert is triggered when the RDS instance has high CPU usage.

## Impact

High CPU usage degrades database performance.

## Diagnosis

1. Open RDS Performance Insights to identify queries consuming the server's CPU.

1. Check queries that are currently running on the CPU

    <details>
    <summary>SQL</summary>

    {{< tabs "mitigation" >}}
    {{< tab "PostgreSQL" >}}
{{% sql "sql/list-queries-using-cpu.sql" %}}
    {{< /tab >}}
    {{< /tabs >}}

    </details>

## Mitigation

- Kill CPU-intensive SQL queries

- Reduce the number of database connections

- Check CPU and disk saturation. You may need to upscale the RDS instance

## Additional resources

- <https://www.postgresql.org/docs/current/monitoring-stats.html#WAIT-EVENT-TABLE>
- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/wait-event.cpu.html>
