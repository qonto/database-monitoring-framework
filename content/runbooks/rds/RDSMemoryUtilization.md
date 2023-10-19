---
title: Memory utilization
---

# RDSMemoryUtilization

## Meaning

Alert is triggered when an RDS instance has low available memory

## Impact

- Performanced could be degraded
- Very low freeable memory causes unexpected downtime on your instance

## Diagnosis

1. Examine clients connected to the database

    Even when inactive, connected clients consume memory on the server.

1. Check review hardware configuration

## Mitigation

1. Reduce number of connected clients (and/or max connections)

1. Upscale instance type

    {{% aws-rds-modify-instance-type %}}

## Additional resources

- <https://repost.aws/knowledge-center/rds-sql-server-correct-low-memory>
- <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.Performance.RAM>
