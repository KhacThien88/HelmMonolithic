{{- define "common.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Values.appName }}-deployment"
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ .Values.appName }}
spec:
  replicas: {{ .Values.replicaCount | default 1 }}
  revisionHistoryLimit: {{ .Values.revisionHistoryLimit | default 10 }}
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
        env: {{ .Values.env | default "production" }}
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                  - key: env
                    operator: In
                    values:
                      - {{ .Values.env | default "production" }}
                topologyKey: kubernetes.io/hostname
      dnsPolicy: ClusterFirst
      restartPolicy: Always
{{- if .Values.initContainers }}
      initContainers:
{{ toYaml .Values.initContainers | indent 8 }}
{{- end }}
      containers:
        - name: {{ .Values.appName }}
          image: {{ .Values.image.repository }}:{{ .Values.image.tag | default "latest" }}
          ports:
            - containerPort: {{ .Values.service.port | default 5000 }}
              name: {{ .Values.service.name | default "http" }}
              protocol: TCP
          {{- if or (eq .Values.appName "todoapp-backend-dev") (eq .Values.appName "todoapp-backend-staging") }}
          env:
            - name: DB_HOST
              value: {{ .Values.database.host | default "mysql-service" }}
            - name: USERNAME
              value: {{ .Values.database.username | quote }}
            - name: PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.database.secretName | default "mysql-secrets" }}
                  key: password
            - name: DB_NAME
              value: {{ .Values.database.name | default "tasks_db" }}
            - name: DB_PORT
              value: {{ .Values.database.port | default "3306" | quote }}
          {{- end }}
          {{- if eq .Values.appName "todoapp-frontend-dev" }}
          env:
            - name: API_URL
              value: "https://{{ .Values.backend.ingress.domainDevName }}"
          {{- end }}
          {{- if eq .Values.appName "todoapp-frontend-staging" }}
          env:
            - name: API_URL
              value: "https://{{ .Values.backend.ingress.domainStagingName }}"
          {{- end }}
          # livenessProbe:
          #   httpGet:
          #     path: /tasks
          #     port: {{ .Values.service.port | default 5000 }}
          #   initialDelaySeconds: 30
          #   periodSeconds: 10
          # readinessProbe:
          #   httpGet:
          #     path: /tasks
          #     port: {{ .Values.service.port | default 5000 }}
          #   initialDelaySeconds: 5
          #   periodSeconds: 5
{{- end }}