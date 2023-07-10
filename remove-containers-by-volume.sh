#!/bin/bash

VOLUME_NAME="$1"

# Check if volume name is provided
if [[ -z "$VOLUME_NAME" ]]; then
  echo "Please provide the name of the Docker volume."
  exit 1
fi

# Get a list of all containers associated with the volume
CONTAINERS=$(docker ps -a --filter "volume=$VOLUME_NAME" --format "{{.ID}}")

# Check if any containers are associated with the volume
if [[ -z "$CONTAINERS" ]]; then
  echo "No containers found associated with the volume $VOLUME_NAME."
  exit 0
fi

# Remove each container associated with the volume
for CONTAINER_ID in $CONTAINERS; do
  echo "Removing container $CONTAINER_ID..."
  docker rm "$CONTAINER_ID"
done

echo "All containers associated with the volume $VOLUME_NAME have been removed."

