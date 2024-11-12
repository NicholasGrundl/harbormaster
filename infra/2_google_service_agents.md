# Deployment Service Agent Setup and Management

This document outlines the process for creating, managing, and securing a service agent that can pull images from Google Artifact Registry (GAR).

## Initial Setup

### 0. Setup envrionment configuration variables

Add the following to our `.env.config` file

```bash
VPS_REGISTRY_SERVICE_ACCOUNT=vps-artifact-registry-puller
VPS_KEY_PATH=~/.vps-secrets/gar-sa-key.json
```

### 1. Create a Service Account

Create a named service account for read only docker image pulling

```bash
gcloud iam service-accounts create $VPS_REGISTRY_SERVICE_ACCOUNT --display-name "Google Artifact Registry Puller for VPS"
```

### 2. Grant Permissions

Grant the read only permissions to the created service accound

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$VPS_REGISTRY_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/artifactregistry.reader
```

### Verify service agent in google cloud console

You can navigate to the following URL and check for the service worker:

```bash
https://console.cloud.google.com/iam-admin/serviceaccounts
```

You should see a service accoutn with the anme and read only access here