#!/bin/bash
set -e  # Exit immediately if any command fails

# Define excluded directories
EXCLUDED_DIRS=("docker-compose" "helm" ".idea" "kubernetes")

# Build the find command exclude parameters dynamically
EXCLUDE_ARGS=()
for dir in "${EXCLUDED_DIRS[@]}"; do
  EXCLUDE_ARGS+=(! -name "$dir")
done

# Find subdirectories (excluding specified ones)
find . -maxdepth 1 -type d ! -path "." "${EXCLUDE_ARGS[@]}" -printf "%f\n" | while read -r dir; do
  echo "Processing $dir..."
  pushd "$dir" > /dev/null
  mvn compile jib:dockerBuild || { echo "Maven build failed in $dir"; exit 1; }
  popd > /dev/null
done

echo "All builds completed!"
