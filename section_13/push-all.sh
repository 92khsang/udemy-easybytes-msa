#!/bin/bash

# Get the current directory
BASE_DIR=$(pwd)

# Extract the last number from the directory name (e.g., section8 -> 8)
SECTION_NUM=$(basename "$BASE_DIR" | grep -oE '[0-9]+')

# Define Docker Hub username
DOCKER_USER="92khsang"

# Automatically gather directories, excluding docker-compose and .sh files
dirs=($(find . -maxdepth 1 -type d -not -name "docker-compose" -not -name ".idea" -not -path "." | sed 's|^\./||'))

# Loop through each directory and push the images to Docker Hub
for dir in "${dirs[@]}"; do
  IMAGE_NAME="$DOCKER_USER/$dir:s$SECTION_NUM"
  echo "Pushing image $IMAGE_NAME..."
  docker push "$IMAGE_NAME"
  if [ $? -ne 0 ]; then
    echo "Failed to push image $IMAGE_NAME"
    exit 1
  fi
done

echo "All images pushed successfully!"