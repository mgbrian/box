#!/bin/bash

# -------------------------------------------
# Cleanup script.
#
# Deletes image, container and optionally persisted identity/data.
#
#   ./cleanup.sh
#       Removes image and container; preserves machine identity and persisted data
#
#   ./cleanup.sh --reset-identity
#       Removes image/container and resets machine identity/CRD config
#
#   ./cleanup.sh --delete-data
#       Removes image/container and deletes synced home data
#
#   ./cleanup.sh --all
#       Removes image/container, resets identity, and deletes synced home data
# -------------------------------------------

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
        --all)
            RESET_IDENTITY=true
            DELETE_DATA=true
            ;;
        *)
            echo "Error: Unknown flag '$arg'."
            echo "Usage: ./cleanup.sh [--reset-identity] [--delete-data] [--all]"
            exit 1
            ;;
    esac
done

echo "--- Cleaning up ---"

docker rm -f $CONTAINER_NAME 2>/dev/null || true
docker rmi -f $IMAGE_NAME 2>/dev/null || true

if [ "$RESET_IDENTITY" = true ]; then
    echo "--- Wiping Machine Identity and CRD Config ---"
    rm -rf "$HOST_CONFIG_DIR"
fi

if [ "$DELETE_DATA" = true ]; then
    echo "--- Deleting Persisted Home Data ---"
    rm -rf "$HOST_HOME_MAP"
fi

if [ "$RESET_IDENTITY" = false ] && [ "$DELETE_DATA" = false ]; then
    echo "Machine identity/CRD config preserved."
    echo "Persisted home data preserved."
fi

echo "Cleanup complete."
