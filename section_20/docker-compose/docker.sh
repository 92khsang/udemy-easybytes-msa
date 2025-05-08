#!/bin/bash

SPRING_PROFILES_ACTIVE=default
MINIO_VOLUME_PATH=.data/minio/${SPRING_PROFILES_ACTIVE}
KAFKA_VOLUME_PATH=.data/kafka/${SPRING_PROFILES_ACTIVE}

# 1. Set environment variables
# Extracting directory name for TAG_NAME from the parent directory
PARENT_DIR_NAME=$(basename "$(dirname "$(pwd)")")
# Correctly extract the number part after "section"
SECTION_NUM=$(echo "$PARENT_DIR_NAME" | grep -oE 'section[_]?([0-9]+)' | grep -oE '[0-9]+')
# Create TAG_NAME, use two digits if available, otherwise use the single digit
if [ ${#SECTION_NUM} -ge 2 ]; then
  TAG_NAME="s${SECTION_NUM: -2}"
else
  TAG_NAME="s${SECTION_NUM}"
fi

# Function to print usage information
usage() {
  echo "Usage: $0 -p [profile] -c [config|up|down] [--debug]"
  echo "  -p  Set profile (default/qa/prod)"
  echo "  -c  Choose action: config, up, or down"
  echo "  --debug  Show debug information"
  echo ""
  echo "Example: $0 -p default -c up"
  exit 1
}

# Function to display debug information
show_debug_info() {
  echo "Debug Information:"
  echo "  TAG_NAME: $TAG_NAME"
  echo "  Profile: $SPRING_PROFILES_ACTIVE"
  echo "  MINIO_VOLUME_PATH: $MINIO_VOLUME_PATH"
  echo "  KAFKA_VOLUME_PATH: $KAFKA_VOLUME_PATH"
  echo "  Action: $ACTION"
  exit 0
}

# 2. Parse input options
while getopts "p:c:-:" opt; do
  case $opt in
    p)
      SPRING_PROFILES_ACTIVE=$OPTARG
      MINIO_VOLUME_PATH=.data/minio/${SPRING_PROFILES_ACTIVE}
      KAFKA_VOLUME_PATH=.data/kafka/${SPRING_PROFILES_ACTIVE}
      ;;
    c)
      ACTION=$OPTARG
      ;;
    -)
      if [ "$OPTARG" == "debug" ]; then
        show_debug_info
      else
        usage
      fi
      ;;
    *)
      usage
      ;;
  esac
done

# Check if required parameters are set
if [ -z "$SPRING_PROFILES_ACTIVE" ] || [ -z "$ACTION" ]; then
  usage
fi

# Validate profile
if [[ "$SPRING_PROFILES_ACTIVE" != "default" && "$SPRING_PROFILES_ACTIVE" != "qa" && "$SPRING_PROFILES_ACTIVE" != "prod" ]]; then
  echo "Invalid profile. Choose one of: default, qa, prod."
  exit 1
fi

# 3. Docker compose file paths
DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose.observability.yml"

export SPRING_PROFILES_ACTIVE
export MINIO_VOLUME_PATH
export KAFKA_VOLUME_PATH
export TAG_NAME

# Execute actions based on the provided command
case $ACTION in
  config)
    # Show the Docker Compose configuration
    docker compose $DOCKER_COMPOSE_FILES config
    ;;
  up)
    # Bring up Docker Compose with the specified profile
    docker compose $DOCKER_COMPOSE_FILES up -d
    ;;
  down)
    # Bring down Docker Compose
    docker compose $DOCKER_COMPOSE_FILES down
    ;;
  *)
    echo "Invalid action. Choose one of: config, up, down."
    usage
    ;;
esac
