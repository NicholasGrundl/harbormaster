#!/bin/bash

set -e

#change to the dir containing the scripts
cd ~/vps-config

# Load custom function(s)  and environment variables
source .bash_vps_functions
set_environment .env.config

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Authenticate with Google Artifact Registry
log "Authenticating with Google Artifact Registry..."
gcloud auth activate-service-account --key-file=$VPS_KEY_PATH

# Pull latest images
log "Pulling latest images from GAR..."
docker pull $ARTIFACT_REGISTRY_HOST/$IMAGE_FRONTEND:latest
docker pull $ARTIFACT_REGISTRY_HOST/$IMAGE_BACKEND:latest
docker pull $ARTIFACT_REGISTRY_HOST/$IMAGE_NGINX:latest


# Stop running containers
log "Stopping running containers..."
docker compose down

# Start new containers
log "Starting new containers..."
docker compose up -d

# Optional health check
# log "Verifying deployment..."
# MAX_RETRIES=2
# RETRY_INTERVAL=10
# HEALTH_CHECK_ENDPOINT="/api/health"  # Adjust this to your actual health check endpoint

# for i in $(seq 1 $MAX_RETRIES); do
#     if curl -sSf -k "https://localhost${HEALTH_CHECK_ENDPOINT}" > /dev/null 2>&1 || \
#        curl -sSf "http://localhost${HEALTH_CHECK_ENDPOINT}" > /dev/null 2>&1; then
#         log "Deployment successful!"
#         exit 0
#     else
#         log "Attempt $i: Services not ready yet. Retrying in $RETRY_INTERVAL seconds..."
#         sleep $RETRY_INTERVAL
#     fi
# done

# log "Deployment failed. Rolling back..."
# docker compose down
# docker compose up -d --no-deps --build
# exit 1