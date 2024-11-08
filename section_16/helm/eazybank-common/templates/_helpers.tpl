{{- define "eazybank.createDeployment" -}}
{{- if and .Values.deployment }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.createService" -}}
{{- if and .Values.service }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.createConfigMap" -}}
{{- if and .Values.global.configMapName }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.createSecret" -}}
{{- if and .Values.secretSet }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.createSecretEnv" -}}
{{- if and .Values.envSecretSets }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.images.image" -}}
{{- $imageRoot := .imageRoot -}}
{{- $global := .global -}}
{{- $registry := $imageRoot.registry | default $global.registry -}}
{{- $repository := $imageRoot.repository | default $global.repository -}}
{{- $tag := $imageRoot.tag | default $global.tag -}}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else }}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.image" -}}
{{- include "eazybank.images.image" (dict "imageRoot" .Values.deployment.image "global" .Values.global) -}}
{{- end -}}

{{- define "eazybank.deploymentName" -}}
{{ printf "%s-deployment" .Values.deployment.appName | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "eazybank.serviceName" -}}
{{ printf "%s-service" .Values.service.appName | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "eazybank.labelName" -}}
{{ printf "%s-label" .appName | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "eazybank.activeProfile" -}}
{{ .Values.deployment.activeProfile | default .Values.global.activeProfile }}
{{- end -}}

{{- define "eazybank.envAppNameSets" -}}
{{- $appName := .Values.deployment.appName }}
{{- $envAppNameSets := .Values.envAppNameSets }}
{{- $enabledFeatures := .Values.enabledFeatures }}
{{- range $envAppNameSets }}
  {{- if has .feature $enabledFeatures }}
- name: {{ .envName }}
  value: {{ $appName }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "eazybank.keyRef" -}}
valueFrom:
{{- .keyRefType | nindent 4 -}}:
{{- printf "name: %s" .name | nindent 6  -}}
{{- printf "key: %s" .key | nindent 6  -}}
{{- end -}}

{{- define "eazybank.envConfigSets" -}}
{{- $configMapName := .Values.global.configMapName }}
{{- $envConfigSets := .Values.envConfigSets }}
{{- $enabledFeatures := .Values.enabledFeatures }}
{{- range $envConfigSets }}
  {{- if has .feature $enabledFeatures }}
    {{- if kindIs "slice" .envName }}
      {{- range .envName }}
- name: {{ . }}
{{ include "eazybank.keyRef" (dict "keyRefType" "configMapKeyRef" "name" $configMapName "key" .) | indent 2 }}
      {{- end -}}
    {{- else }}
- name: {{ .envName }}
{{ include "eazybank.keyRef" (dict "keyRefType" "configMapKeyRef" "name" $configMapName "key" .envName) | indent 2 }}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}


{{- define "eazybank.envSecretSets" -}}
{{- range .Values.envSecretSets }}
{{- $secretName := .name }}
    {{- range .entries }}
- name: {{ .envName }}
{{ include "eazybank.keyRef" (dict "keyRefType" "secretKeyRef" "name" $secretName "key" .secretKeyName) | indent 2 }}
    {{- end -}}
{{- end -}}
{{- end -}}