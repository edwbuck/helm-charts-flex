{{/*
Expand the name of the chart.
*/}}
{{- define "spire-flex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spire-flex.fullname" -}}
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
{{- define "spire-flex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spire-flex.labels" -}}
helm.sh/chart: {{ include "spire-flex.chart" . }}
{{ include "spire-flex.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spire-flex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spire-flex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spire-flex.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spire-flex.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Returns the agent image string.
*/}}
{{- define "spire-flex.agent.image" -}}
{{ join "" (list 
       (coalesce ((.Values.agent).image).registry (.Values.image).registry "ghcr.io")
       (ternary "" ":" (empty (coalesce ((.Values.agent).image).registryPort (.Values.image).registryPort)))
       (coalesce ((.Values.agent).image).registryPort (.Values.image).registryPort)
       "/" (coalesce ((.Values.agent).image).name "spiffe/spire-agent") ":"
       (coalesce ((.Values.agent).image).tag (.Values.image).tag .Chart.AppVersion)
   ) | quote }}
{{- end }}

{{/*
Returns the server image string.
*/}}
{{- define "spire-flex.server.image" -}}
{{ join "" (list 
       (coalesce ((.Values.server).image).registry (.Values.image).registry "ghcr.io")
       (ternary "" ":" (empty (coalesce ((.Values.server).image).registryPort (.Values.image).registryPort)))
       (coalesce ((.Values.server).image).registryPort (.Values.image).registryPort)
       "/" (coalesce ((.Values.server).image).name "spiffe/spire-server") ":"
       (coalesce ((.Values.server).image).tag (.Values.image).tag .Chart.AppVersion)
   ) | quote }}
{{- end }}
