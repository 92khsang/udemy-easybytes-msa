#!/bin/bash
set -e  # Exit immediately if any command fails

# Get the current directory
BASE_DIR=$(pwd)

# Extract the last number from the directory name (e.g., section8 -> 8)
SECTION_NUM=$(basename "$BASE_DIR" | grep -oE '[0-9]+')

# Define Docker Hub username
DOCKER_USER="92khsang"

# Define excluded directories
EXCLUDED_DIRS=("docker-compose" ".idea" "kubernetes" "helm")

# Build the find command exclude parameters dynamically
EXCLUDE_ARGS=()
for dir in "${EXCLUDED_DIRS[@]}"; do
  EXCLUDE_ARGS+=(! -name "$dir")
done

# Find subdirectories (excluding specified ones) and push images
find . -maxdepth 1 -type d ! -path "." "${EXCLUDE_ARGS[@]}" -printf "%f\n" | while read -r dir; do
  IMAGE_NAME="$DOCKER_USER/$dir:s$SECTION_NUM"
  echo "Pushing image $IMAGE_NAME..."
  docker push "$IMAGE_NAME"
done

echo "All images pushed successfully!"
