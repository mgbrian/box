#!/bin/bash

source ./config.sh

echo "--- Cleaning up ---"

docker rm -f $CONTAINER_NAME 2>/dev/null || true
docker rmi -f $IMAGE_NAME 2>/dev/null || true
rm -rf "$HOST_CONFIG_DIR"

echo "Cleanup complete."
