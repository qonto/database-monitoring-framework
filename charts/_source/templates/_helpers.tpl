{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return boolean for the specified value, with true as default
*/}}
{{- define "chart.boolWithDefaultTrue" -}}
    {{- $content := . | toYaml -}}
    {{- $output := "" -}}
    {{- if or (eq $content "null") (eq $content "true") (eq $content "yes") (eq $content "on") -}}
        {{- $output = "1" -}}
    {{- end -}}
    {{ $output }}
{{- end -}}

{{/*
Render Prometheus rule
*/}}
{{ define "chart.renderPrometheusRule" }}
{{- $ruleIsEnabled := .enabled | include "chart.boolWithDefaultTrue" -}}
{{- $expr := .expr -}}
{{- $name := .name -}}
{{- $pintComments := default dict .pintComments -}}
{{- $for := .for -}}
{{- $keepFiringFor := default .defaultKeepFiringFor .keepFiringFor -}}
{{- $ruleLabels := .labels -}}
{{- $record := .record -}}
{{- $annotations := default dict .annotations -}}
{{- $additionalRuleLabels := default list .additionalRuleLabels -}}
{{- $globalAdditionalExprLabels := default list .globalAdditionalExprLabels -}}
{{- $exprLabels := concat $globalAdditionalExprLabels $additionalRuleLabels | uniq -}}
{{- $defaultRunbookUrl := .defaultRunbookUrl -}}
{{- $chartVersion := .chartVersion -}}

{{- $globalAdditionalRuleLabels := default dict .globalAdditionalRuleLabels -}}
{{- $labels := merge $ruleLabels $globalAdditionalRuleLabels -}}

{{- $additionalExprLabels := printf "%s" (join "," $exprLabels) }}
{{- if $additionalExprLabels }}
{{- $additionalExprLabels = printf "%s," $additionalExprLabels }}
{{- end }}

{{- /* Set default runbook URL */ -}}
{{- if and (not $annotations.runbook_url) ($defaultRunbookUrl) }}
{{- $_ := set $annotations "runbook_url" $defaultRunbookUrl }}
{{- end }}
{{- /* Replace variables in runbook URL */ -}}
{{- if $annotations.runbook_url }}
{{- $_ := set $annotations "runbook_url" ($annotations.runbook_url | replace "{{alertName}}" $name | replace "{{chartVersion}}" $chartVersion ) }}
{{- end }}

{{- if $ruleIsEnabled }}
- alert: {{ $name | quote }}
  {{- if $pintComments }}
  {{- range $pintComment := $pintComments }}
  # pint {{ $pintComment }}
  {{- end }}
  {{- end }}
  expr: |
{{ $expr | replace "[additionalExprLabels]" $additionalExprLabels | indent 4 }}
  {{- if $record }}
  record: {{ $record }}
  {{- end }}
  {{- if $for }}
  for: {{ $for }}
  {{- end }}
  {{- if $keepFiringFor }}
  keep_firing_for: {{ $keepFiringFor }}
  {{- end }}
{{- if $labels }}
  labels:
{{ $labels | toYaml | indent 4 }}
{{- end }}
{{- if $annotations }}
  annotations:
{{ $annotations | toYaml | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
