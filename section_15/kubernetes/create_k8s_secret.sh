#!/bin/bash

# Load environment variables from .env file
set -a
source .env
set +a

# Check if required environment variables are set
if [[ -z "$SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME" || -z "$SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD" ]]; then
  echo "Error: Required environment variables are missing in .env file."
  exit 1
fi

# Create Kubernetes secret using environment variables
kubectl create secret generic configserver-github-credentials \
  --from-literal=username="$SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME" \
  --from-literal=password="$SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD"

echo "Secret 'configserver-github-credentials' created successfully."
