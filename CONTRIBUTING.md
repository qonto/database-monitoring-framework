# Contributing

Database Monitoring Framework uses GitHub to manage reviews of pull requests.

* If you are a new contributor. See: [Steps to Contribute](#steps-to-contribute)

* If you have a trivial fix or improvement, go ahead and create a pull request

* Be sure to enable [signed commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)

## Steps to Contribute

Should you wish to work on an issue, please claim it first by commenting on the GitHub issue that you want to work on it. This is to prevent duplicated efforts from contributors on the same issue.

All our issues are regularly tagged so you can filter down the issues involving the components you want to work on.

We use :

* [`pre-commit`](https://pre-commit.com) to have style consistency in runbooks.
* [`markdownlint-cli2`](https://github.com/DavidAnson/markdownlint-cli2) for linting the Markdown document. If you think the linter is incorrect, look at [configuration](https://github.com/DavidAnson/markdownlint/blob/main/README.md#configuration) to ignore the line.
* Gitlab workflows to run tests

## Pull Request Checklist

Git

* Branch from the `main` branch and, if needed, rebase to the current main branch before submitting your pull request. If it doesn't merge cleanly with main you may be asked to rebase your changes.

* Commits should be as small as possible while ensuring each commit is correct independently (i.e., each commit should compile and pass tests).

* Commits message must use [Conventional commits format](https://www.conventionalcommits.org/)

Alerts

* Alerts must have a runbook that matches the runbook template. All sections must be present. If a section is non-applicable, use `n/a`.

* Alerts guideline:

  * An alert must lead to an action on the system
  * Alert name must be captialized, prefixed by the component name (e.g. `PosgreSQL`) and short but explicit
  * Summary annotation must explains the alert
  * Description annotation is recommanded to provide more details about the alert
  * Severity label must be `critical` if system has broken or it's imminent, othewise it should be `warning`

* See [My Philosophy on Alerting
](https://docs.google.com/document/d/199PqyG3UsyXlwieHaqbGiWVa8eMWi8zzAn0YfcApr8Q/edit) from *Rob Ewaschuk*

## Development environment

To have Hugo templates resolution, we recommend to edit pages using Hugo webserver:

1. Clone repository and its submodules (contains Hugo template)

    ```bash
    git clone --recurse-submodules git@github.com:qonto/database-monitoring-framework.git
    ```

1. Start local hugo webserver using docker compose

    ```bash
    docker compose up
    ```

1. Go to <http://localhost:1313>

## Install pre-commit

1. Install [pre-commit](https://pre-commit.com/)

1. Install [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)

1. Enable pre-commit for the repository

    ```bash
    pre-commit install
    ```

## Run tests

`make all-tests` run all tests, but you can run them manually:

```bash
make helm-test # Helm unit tests
make kubeconform-test # Check Helm charts render valid Kubernetes manifests
make runbook-test # Test runbooks
```

Tests on SQL queries (files with `.sql` extension) are tested accross a PostgreSQL instance and need to be launched manually.

1. Start a PostgreSQL instance with a `test` database

    ```bash
    docker run -e POSTGRES_PASSWORD=hackme -e POSTGRES_DB=test -p 5432:5432 postgres:16
    ```

2. Launch PostgreSQL tests in a second terminal

    ```bash
    PGHOST=localhost PGUSER=postgres PGPASSWORD=hackme PGDATABASE=test make sql-test
    ```

## Golden rules

Any alerts:

* Must lead to an action
* Must have a runbook
* Not generate false positive alert (see [alert fatigue](https://en.wikipedia.org/wiki/Alarm_fatigue))
* Could be customized

Any runboks:

* Explains why the alert is raied
* Estimates the impact on systems
* Help to find the root cause
* Provides guidelines to mitigate the situation

## Add a new alert

1. New alert must follow the [golden rules]({{< relref "#golden-rules" >}}).

    Naming convention:

    * Alert name uses CamelCase format
    * Prefixed with the component name (eg. `PostgreSQL<AlertName>`)

1. Add runbook in `content/runbooks/<component>/<alertName>.md`

    ```bash
    make new-runbook > content/runbooks/<component>/<alertName>.md
    ```

    For attractive layout, look at:
    * <https://hugo-book-demo.netlify.app>
    * <https://gohugo.io/documentation>

1. Add alert in `chart/prometheus-<component>-alerts/values.yaml`

    ```yaml
    <alertName>:
      expr: <prometheusRule>
      for: <duration_in_minutes>
      labels:
        priority: <priority>
      annotations:
        message: "<comprehensive description of the alert>"
    ```

1. Run tests

    ```bash
    make all-tests
    pre-commit run --all-files # or use "pre-commit install" to install git hook
    ```

1. Submit pull request on Github
