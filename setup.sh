#!/bin/bash

set -e
source ./config.sh

# Delete the old image, container and persisted data.
./cleanup.sh

echo "--- Building Image ($PLATFORM) ---"

docker build --platform $PLATFORM -t $IMAGE_NAME .

# Run CRD auth flow
./auth.sh
