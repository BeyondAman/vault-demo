{{/* This file is for defining helper functions */}}

{{- define "sample-app-chart.image.repository" -}}
{{- default "au06/demo-app" .Values.image.repository -}}
{{- end }}

{{- define "sample-app-chart.image.tag" -}}
{{- default "0.0.1" .Values.image.tag -}}
{{- end }}

{{- define "sample-app-chart.serviceAccountName" -}}
{{- default "vault-demo" .Values.serviceAccountName -}}
{{- end }}

{{- define "sample-app-chart.configMapName" -}}
{{- default "variables-path" .Values.configMapName -}}
{{- end }}
