#!/bin/bash

# Check if IMAGE_NAME is set
if [ -z "$IMAGE_NAME" ]; then
    echo "Error: IMAGE_NAME is not set"
    exit 1
fi

# Check if ARTIFACT_REGISTRY_HOST is set
if [ -z "$ARTIFACT_REGISTRY_HOST" ]; then
    echo "Error: ARTIFACT_REGISTRY_HOST is not set"
    exit 1
fi

# Use IMAGE_TAG if set, otherwise use 'latest'
TAG=${IMAGE_TAG:-latest}

# Push the image to Google Artifact Registry
docker push ${ARTIFACT_REGISTRY_HOST}/${IMAGE_NAME}:${TAG}

# Check if the push was successful
if [ $? -eq 0 ]; then
    echo "Successfully pushed ${IMAGE_NAME}:${TAG} to ${ARTIFACT_REGISTRY_HOST}"
else
    echo "Failed to push ${IMAGE_NAME}:${TAG} to ${ARTIFACT_REGISTRY_HOST}"
    exit 1
fi