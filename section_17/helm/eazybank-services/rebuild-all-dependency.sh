#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Exit if any part of a pipeline fails

# Define common and services directories relative to the current directory
COMMON_DIR="../eazybank-common"

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
    echo "Running helm dependency update for $(basename "$dir")..."
    helm dependency update "$dir"
  done
}

# Function to prompt user for a specific directory
choose_directory() {
  local base_dir="$1"
  echo "Available subdirectories in $base_dir:"
  select dir in $(find "$base_dir" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;); do
    if [[ -n "$dir" ]]; then
      echo "You selected $dir. Running helm dependency update for this directory..."
      helm dependency update "$base_dir/$dir"
      helm template "$dir" --debug
      break
    else
      echo "Invalid selection. Please choose a number from the list."
    fi
  done
}

# Run helm dependency update for all subdirectories or prompt for a specific one
echo "Would you like to update all subdirectories in the current directory or choose one?"
echo "1) Update all"
echo "2) Choose a specific subdirectory"
read -rp "Select an option (1 or 2): " choice

if [[ "$choice" -eq 1 ]]; then
  update_helm_dependencies "."
elif [[ "$choice" -eq 2 ]]; then
  choose_directory "."
else
  echo "Invalid choice. Exiting."
  exit 1
fi
