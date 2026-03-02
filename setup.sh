#!/bin/bash

set -e
source ./config.sh

RESET_IDENTITY=false
DELETE_DATA=false

for arg in "$@"; do
    case "$arg" in
        --reset-identity)
            RESET_IDENTITY=true
            ;;
        --delete-data)
            DELETE_DATA=true
            ;;
        --new)
            RESET_IDENTITY=true
            DELETE_DATA=true
            ;;
        *)
            echo "Error: Unknown flag '$arg'."
            echo "Usage: ./setup.sh [--reset-identity] [--delete-data] [--new]"
            exit 1
            ;;
    esac
done

CLEANUP_ARGS=()
[ "$RESET_IDENTITY" = true ] && CLEANUP_ARGS+=("--reset-identity")
[ "$DELETE_DATA" = true ] && CLEANUP_ARGS+=("--delete-data")

# Delete the old image/container and optionally reset identity/data.
./cleanup.sh "${CLEANUP_ARGS[@]}"

echo "--- Building Image ($PLATFORM) ---"

docker build \
    --platform $PLATFORM \
    --build-arg CRD_USER="$CRD_USER" \
    --build-arg CRD_PASSWORD="$CRD_PASSWORD" \
    -t $IMAGE_NAME .

# Run CRD auth flow if no existing config, else just start the container.
if ls "$HOST_CONFIG_DIR"/host#*.json 1> /dev/null 2>&1; then
    echo "Existing Identity found. Skipping Auth. Starting container..."

    ./start.sh
else
    echo "--- No Identity found. Beginning auth... ---"
    ./auth.sh
fi
