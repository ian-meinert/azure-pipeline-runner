# azure-pipeline-runner

## Build and Push Container Image

`docker login` or `podman login`

`docker build -t azurerunner:v1 .` or `podman build -t azurerunner:v1 .`

`podman tag localhost/azurerunner:v1 YourImageRegistryURL.com:v1`

`docker push YourImageRegistryURL.com:v1` or `podman push YourImageRegistryURL.com:v1`



## Option A - Run container locally

`podman run -e AZP_URL="<Azure DevOps instance>" -e AZP_TOKEN="<Personal Access Token>" -e AZP_POOL="<Agent Pool Name>" -e AZP_AGENT_NAME="Docker Agent - Linux" --name "azp-agent-linux" localhost/azurerunner:v1`

------

## Option B - Run on Kubernetes/OpenShift
1. Apply the Secret resource YAML then manually modify it afterwards with your values:

```
apiVersion: v1
kind: Secret
metadata:
  name: azure-pipelines-agent-secret
type: Opaque
data:
  AZP_TOKEN: cGFzc3dvcmQxMjM=  # This is "password123" base64 encoded
  AZP_URL: cGFzc3dvcmQxMjM= # https://domain.com/org/
  AZP_POOL: cGFzc3dvcmQxMjM= # Pool name
  AZP_AGENT_NAME: YXp1cmUtcGlwZWxpbmVzLWFnZW50Cg== # "azure-pipelines-agent"
```

2. Apply the Deployment Resource YAML

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-pipelines-agent
  labels:
    app.kubernetes.io/name: azure-pipelines-agent
    app.kubernetes.io/instance: agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: azure-pipelines-agent
      app.kubernetes.io/instance: agent
  template:
    metadata:
      labels:
        app.kubernetes.io/name: azure-pipelines-agent
        app.kubernetes.io/instance: agent
    spec:
      containers:
        - name: azure-pipelines-agent
          image: registry.access.redhat.com/ubi9/ubi-minimal:9.4-1134
          imagePullPolicy: Always
          env:
            - name: AZP_AGENT_NAME
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.name
            - name: AZP_URL
              valueFrom: 
                secretKeyRef:
                  key: AZP_URL
                  name: azure-pipelines-agent-secret
            - name: AZP_POOL
              valueFrom: 
                secretKeyRef:
                  key: AZP_POOL
                  name: azure-pipelines-agent-secret
            - name: AZP_TOKEN
              valueFrom: 
                secretKeyRef:
                  key: AZP_TOKEN
                  name: azure-pipelines-agent-secret
            - name: AZP_AGENT_NAME
              valueFrom: 
                secretKeyRef:
                  key: AZP_AGENT_NAME
                  name: azure-pipelines-agent-secret
```
