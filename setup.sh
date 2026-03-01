#!/bin/bash

set -e
source ./config.sh

# Delete the old image, container and persisted data.
./cleanup.sh

echo "--- Building Image ($PLATFORM) ---"

docker build --platform $PLATFORM -t $IMAGE_NAME .

# Run CRD auth flow if no existing config, else just start the container.
if ls "$HOST_CONFIG_DIR"/host#*.json 1> /dev/null 2>&1; then
    echo "Existing Identity found. Skipping Auth. Starting container..."

    ./start.sh
else
    echo "--- No Identity found. Beginning auth... ---"
    ./auth.sh
fi
