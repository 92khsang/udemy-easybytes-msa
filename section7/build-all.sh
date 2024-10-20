#!/bin/bash

# Get the current directory
BASE_DIR=$(pwd)

# List of directories to process (excluding docker-compose)
dirs=("accounts" "cards" "configserver" "loans")

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

