SHELL=/bin/bash -o pipefail
kubeconform_command := kubeconform -kubernetes-version $${KUBERNETES_VERSION-1.25.0} -cache $${KUBECONFORM_CACHE_DIRECTORY-/tmp} -summary -exit-on-error --strict -schema-location default -schema-location 'kubeconform/{{ .ResourceKind }}{{ .KindSuffix }}.json' -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
AWS_ECR_PUBLIC_ORGANIZATION=qonto
PGDATABASE=test

.PHONY: helm-test
helm-test:
	helm unittest charts/*

.PHONY: kubeconform-test
kubeconform-test:
	helm template charts/prometheus-postgresql-alerts | $(kubeconform_command)
	helm template charts/prometheus-rds-alerts | $(kubeconform_command)

.PHONY: runbook-test
runbook-test:
	./scripts/check_runbook_exists.sh charts/prometheus-rds-alerts content/runbooks/rds
	./scripts/check_runbook_exists.sh charts/prometheus-postgresql-alerts content/runbooks/postgresql

.PHONY: sql-test
sql-test:
	PGHOST=localhost PGUSER=postgres PGPASSWORD=hackme PGDATABASE=test ./scripts/validate_sql_files.sh content $(PGDATABASE)

.PHONY: prometheus-test
prometheus-test:
	./scripts/check_prometheus_rules.sh charts/prometheus-rds-alerts
	./scripts/check_prometheus_rules.sh charts/prometheus-postgresql-alerts

.PHONY: all-tests
all-tests: helm-test kubeconform-test runbook-test sql-test prometheus-test

.PHONY: helm-release
helm-release:
	./scripts/helm-release.sh prometheus-rds-alerts-chart charts/prometheus-rds-alerts $(RELEASE_VERSION) $(AWS_ECR_PUBLIC_ORGANIZATION)
	./scripts/helm-release.sh prometheus-postgresql-alerts-chart charts/prometheus-rds-postgresql $(RELEASE_VERSION) $(AWS_ECR_PUBLIC_ORGANIZATION)

.PHONY: new-runbook
new-runbook:
	@cat scripts/templates/runbook.md
