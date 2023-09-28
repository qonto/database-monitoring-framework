---
title: Available memory
---

# RDSAvailableMemory

## Meaning

Alert is triggered when an RDS instance has low available memory.

## Impact

- Performances could be degraded

- Some processes could be killed

## Diagnosis

1. Check the number of database connections

    <details>
    <summary>More</summary>
    Database server creates a process for each client. Each process consumes a small amount of memory on the server.
    </details>

## Mitigation

1. Reduce memory usage

    {{< tabs "mitigation" >}}
{{< tab "PostgreSQL" >}}
1. Reduce the maximum number of connections

    Update the `max_connections` RDS parameter to reduce maximum number of clients

1. Limit database connections per user

    You can also reduce the maximum number of connections per PostgreSQL user using

    {{% sql "sql/limit-user-connection-limit.sql" %}}

1. Reduce the [work_mem](https://postgresqlco.nf/doc/en/param/work_mem/)
{{< /tab >}}
{{< /tabs >}}

1. Increase server instance type

    {{% aws-rds-modify-instance-type %}}

## Additional resources

- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Troubleshooting.html#Troubleshooting.FreeableMemory>
