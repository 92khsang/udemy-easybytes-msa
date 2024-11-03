#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Exit if any part of a pipeline fails

# Define common and services directories relative to the current directory
COMMON_DIR="../eazybank-common"
SERVICES_DIR="../eazybank-services"

# Run helm dependency for eazybank-common
echo "Running helm dependency build for eazybank-common..."
if [[ -d "$COMMON_DIR" ]]; then
  helm dependency build "$COMMON_DIR"
else
  echo "Error: Directory $COMMON_DIR does not exist."
  exit 1
fi

# Function to update helm dependencies for each subdirectory within a given directory
update_helm_dependencies() {
  local base_dir="$1"
  echo "Updating helm dependencies in $base_dir..."

  find "$base_dir" -maxdepth 1 -mindepth 1 -type d | while read -r dir; do
    echo "Running helm dependency build for $(basename "$dir")..."
    helm dependency update "$dir"
  done
}

# Run helm dependency update for each subdirectory in eazybank-environments and eazybank-services
update_helm_dependencies "$SERVICES_DIR"
update_helm_dependencies "."
