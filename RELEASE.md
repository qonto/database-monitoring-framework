# Release Process

## Overview

The Database Monitoring Framework project has the following components:

- prometheus-rds-alerts chart
- prometheus-postgresql-alerts chart

## Versioning Strategy

The project is using [Semantic Versioning](https://semver.org):

- MAJOR version may introduce incompatible changes
- MINOR version introduces functionality in a backward compatible manner
- PATCH version introduces backward compatible bug fixes

## Releasing a New Version

The following steps must be done by one of the Database Monitoring Framework Maintainers:

- Verify the CI tests pass before continuing.
- Create a tag using the current `HEAD` of the `main` branch by using `git tag <major>.<minor>.<patch>`
- Push the tag to upstream using `git push origin <major>.<minor>.<patch>`
- This tag will kick-off the [GitHub Release Workflow](https://github.com/qonto/database-monitoring-framework/blob/main/.github/workflows/release.yaml), which will auto-generate GitHub release and publish Helm charts into the container registry
