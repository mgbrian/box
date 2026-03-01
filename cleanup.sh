#!/bin/bash

# -------------------------------------------
# Cleanup script.
#
# Deletes image, container and (optionally) machine identity.
#
#  ** For now, synced home subfolders (Desktop, etc.) are not deleted.
#     You can do this manually.
#
#   ./cleanup.sh
#       Removes image and container; preserves machine identity and persisted data
#
#   ./cleanup.sh --all :
#       Removes image and container, and machine identity. This severs the connection with CRD.
# -------------------------------------------

source ./config.sh

echo "--- Cleaning up ---"

docker rm -f $CONTAINER_NAME 2>/dev/null || true
docker rmi -f $IMAGE_NAME 2>/dev/null || true

# Only wipe the identity if the --all flag is passed
if [[ "$1" == "--all" ]]; then
    echo "--- Wiping Machine Identity and CRD Config ---"
    rm -rf "$HOST_CONFIG_DIR"
    # TODO: Decide whether this should fall under another flag.
    # rm -rf "$HOST_HOME_MAP"
else
    echo "Machine Identity/CRD connection preserved. Run './cleanup.sh --all' for a total reset."
fi

echo "Cleanup complete."
