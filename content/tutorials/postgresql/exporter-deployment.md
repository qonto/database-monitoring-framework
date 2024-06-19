---
title: Exporter deployment
weight: 100
---

# PostgreSQL exporter deployment

In this tutorial, we'll deploy the SQL exporter with our collectors and recommanded configuration to collect all key metrics.

## Requirements

- Helm (v3.0+)
- Kubectl (v1.25+)
- Kubernetes (v1.25+) with cluster admin permissions
- PostgreSQL admin permissions

This tutorial assumes you have some knowledge of Kubernetes, Helm and PostgreSQL.

## Steps

1. Create `prometheus_sql_exporter` PostgreSQL user with `pg_monitor` role

    ```sql
    CREATE ROLE sql_exporter IN ROLE pg_monitor PASSWORD 'hackme' LOGIN; -- You may use a better password
    ```

1. Configure your `values.yaml` file from the [example provided](https://github.com/burningalchemist/sql_exporter/blob/master/helm/values.yaml):
    - Add jobs. Since some collectors only need to be done for the postgres instance, and some others needs to be run at database level, you'll need at least two jobs.

      <details>
      <summary>Example <code>sql_exporter.yaml</code></summary>

        ```yaml
        jobs:
          - job_name: pg-instance-collectors
            collectors:
                - postgres_15_instance_pg_current
                - postgres_15_instance_pg_database
                - postgres_15_instance_pg_replication
                - postgres_15_instance_pg_settings
                - postgres_15_instance_pg_stat_activity
                - postgres_15_instance_pg_stat_bgwriter
            static_configs:
                - targets:
                    pg1: 'pg://sql_exporter:${PASSWORD}@127.0.0.1:25432/postgres'
          - job_name: pg-database-collectors-pg1
            collectors:
                - postgres_15_database_pg_locks
                - postgres_15_database_pg_stat_database
                - postgres_15_database_pg_stat_progress_vacuum
                - postgres_15_database_pg_stat_user_indexes
                - postgres_15_database_pg_stat_user_tables
                - postgres_15_database_pg_statio_user_tables
            static_configs:
                - targets:
                    db1: 'pg://sql_exporter:${PASSWORD}@127.0.0.1:25432/db1'
                    db2: 'pg://sql_exporter:${PASSWORD}@127.0.0.1:25432/db2'

        collector_files:
          - "*.collector.yaml"
        ```

      </details>
    - Download collectors files for your postgresql version from [postgresql-collectors](https://github.com/qonto/postgresql-collectors) project, place them in the same folder. Specify the filenames in the collector_files list. For that we can use CollectorFiles field.

1. Deploy SQL exporter [using provided helm chart](https://github.com/burningalchemist/sql_exporter/tree/master/helm):

    ```bash
    helm repo add sql_exporter https://burningalchemist.github.io/sql_exporter/
    helm repo update
    helm install sql_exporter/sql-exporter
    ```
