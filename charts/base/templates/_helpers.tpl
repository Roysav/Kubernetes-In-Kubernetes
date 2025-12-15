{{/*
Expand the name of the chart.
*/}}
{{- define "base.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "base.fullname" -}}
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
{{- define "base.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "base.labels" -}}
helm.sh/chart: {{ include "base.chart" . }}
{{ include "base.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "base.selectorLabels" -}}
app.kubernetes.io/name: {{ include "base.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "base.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "base.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "base.image" -}}
{{- $global := .Values.global | default (dict "image" (dict)) -}}
{{- $registry := .Values.image.registry | default $global.image.registry -}}
{{- $tag := .Values.image.tag | default $global.image.tag | default "latest" -}}
{{- $repository := .Values.image.repository | required "image.repository is not set" -}}
{{ $registry }}/{{ $repository }}:{{ $tag }}
{{- end -}}


{{- define "base.kv" -}}
{{- range $key, $value := . }}
{{ $key | quote }}: {{ $value | quote }}
{{- end }}
{{- end -}}


{{- define "base.volumes" -}}
{{- range $name := .Values.certificates }}
- name: {{ $name }}-certificate
  secret:
    secretName: {{ $.Release.Name }}-{{ $name }}
{{- end }}
{{- if .Values.kubeConfig.enabled }}
- name: kubeconfig
  configMap:
    name: {{ include "base.fullname" . }}-kube
{{- end }}
{{- range .Values.volumes }}
{{ . | toYaml }}
{{- end }}
{{ tpl .Values.volumesTpl . }}
{{- end -}}

{{- define "base.envFrom" -}}
- configMapRef:
    name: {{ .Release.Name }}-environment
  optional: true
{{- end -}}

