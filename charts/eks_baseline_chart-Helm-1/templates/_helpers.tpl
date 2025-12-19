{{/*
Define el nombre completo del microservicio
*/}}

{{- define "eks-baseline.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | lower | replace "_" "-" | trunc 63 | trimSuffix "-" -}}
{{- end }}


{{/*
Define el nombre del chart con versión
*/}}
{{- define "eks-baseline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Etiquetas comunes estándar
*/}}
{{- define "eks-baseline.labels" -}}
helm.sh/chart: {{ include "eks-baseline.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.bancolombia.com.co/env: {{ .Values.microservice.labels.environment }}
app.bancolombia.com.co/cost-center: {{ .Values.microservice.labels.costCenter }}
app.bancolombia.com.co/application-code: {{ .Values.microservice.labels.applicationCode }}
app.bancolombia.com.co/project: {{ .Values.microservice.labels.projectName }}
app.bancolombia.com.co/pmo: {{ .Values.microservice.labels.pmo }}
app.bancolombia.com.co/responsible: {{ .Values.microservice.labels.responsible }}
{{- end }}