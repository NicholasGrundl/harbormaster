#!/bin/bash
# Use existing evnironment variables
# set -e 

# Load environment variables with expansion from file
set -a; source .env; set +a

# Generate development keys directory
mkdir -p environments/local/keys

# Copy example env if not exists
if [ ! -f environments/local/.env.development ]; then
  cp environments/local/.env.example environments/local/.env.development
  echo "Created .env file from example"
fi

# Generate development keys
if [ ! -f environments/local/keys/dev-dockmaster.key ]; then
  ssh-keygen -t rsa -b 4096 -C "dev dockmaster service account" -f environments/local/keys/dev-dockmaster.key -N ""
  echo "Generated development dockmaster key"
fi

if [ ! -f environments/local/keys/dev-dockyard.key ]; then
  ssh-keygen -t rsa -b 4096 -C "dev dockyard service account" -f environments/local/keys/dev-dockyard.key -N ""
  echo "Generated development dockyard key"
fi

if [ ! -f environments/local/keys/dev-gar-service-account.key ]; then
  # Register a new service account
  echo "Creating a new development Service Account"
  gcloud iam service-accounts create $ARTIFACT_REGISTRY_SERVICE_ACCOUNT --display-name "Development Google Artifact Registry Puller"
  echo "Adding artifact registry reader role to service account"
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$ARTIFACT_REGISTRY_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/artifactregistry.reader
  echo "Creating a development service account key"
  gcloud iam service-accounts keys create environments/local/keys/dev-gar-service-account.key \
  --iam-account $ARTIFACT_REGISTRY_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
  echo "Generated development artifact registry service account"
fi

echo "Development environment setup complete!"

