{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hetzner-webhook.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hetzner-webhook.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hetzner-webhook.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hetzner-webhook.selfSignedIssuer" -}}
{{ printf "%s-selfsign" (include "hetzner-webhook.fullname" .) }}
{{- end -}}

{{- define "hetzner-webhook.rootCAIssuer" -}}
{{ printf "%s-ca" (include "hetzner-webhook.fullname" .) }}
{{- end -}}

{{- define "hetzner-webhook.rootCACertificate" -}}
{{ printf "%s-ca" (include "hetzner-webhook.fullname" .) }}
{{- end -}}

{{- define "hetzner-webhook.servingCertificate" -}}
{{ printf "%s-webhook-tls" (include "hetzner-webhook.fullname" .) }}
{{- end -}}
