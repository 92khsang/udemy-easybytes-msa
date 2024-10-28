#!/bin/bash

# Get the current directory
BASE_DIR=$(pwd)

# Automatically gather directories, excluding docker-compose and .sh files
dirs=($(find . -maxdepth 1 -type d -not -name "docker-compose" -not -name ".idea" -not -path "." | sed 's|^\./||'))

# Loop through each directory and run the maven command
for dir in "${dirs[@]}"; do
  echo "Processing $dir..."
  cd "$BASE_DIR/$dir" || { echo "Directory $dir not found!"; exit 1; }
  mvn compile jib:dockerBuild
  if [ $? -ne 0 ]; then
    echo "Maven build failed in $dir"
    exit 1
  fi
done

echo "All builds completed!"