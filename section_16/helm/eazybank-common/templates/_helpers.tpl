{{- define "eazybank.image" -}}
{{ .Values.image.repository | default .Values.global.repository }}:{{ .Values.image.tag | default .Values.global.tag }}
{{- end -}}

{{- define "eazybank.deploymentName" -}}
{{ printf "%s-deployment" .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "eazybank.serviceName" -}}
{{ printf "%s" .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "eazybank.activeProfile" -}}
{{ .Values.image.activeProfile | default .Values.global.activeProfile }}
{{- end }}
