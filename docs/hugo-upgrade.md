# Hugo upgrade

[Hugo](https://github.com/gohugoio/hugo) engine is frequently updated by the team to add features or bug fixes.

Here is the process to upgrade Hugo:

1. Test new Hugo version locally

    1. Launch Hugo with new version:

        ```bash
        export HUGO_VERSION=<new_version>
        docker compose up
        ```

    1. Check website rendering on <http://localhost:1313>

        Checklist:

        - Check runbook (including SQL rendering) in runbook (e.g. `PostgreSQLInactiveLogicalReplicationSlot` runbook)
        - Check tabs are correctly rendered in tutorials (e.g. `RDS exporter deployment`)
        - Check search engine
        - Check "last update" information in page footer

1. Upgrade Hugo version for local development environment in `docker-compose.yaml`

1. Upgrade Hugo version for CI in `.github/workflows/release.yaml`
