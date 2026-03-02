#!/bin/bash

# -------------------------------------------
# Global config variables. Update as needed.
# -------------------------------------------

# Docker image name
IMAGE_NAME="ubuntu-crd"
# Docker container name
CONTAINER_NAME="remote-desktop"
# The name of the machine as should appear in Chrome Remote Desktop
CRD_HOSTNAME="the-box"

# Remote desktop user credentials inside the container.
# Both of these can be overriden in .env.
CRD_USER="crduser"
CRD_PASSWORD="crdpassword"

# Persisted data folders
# Path to the folder containing persisted CRD config data
HOST_CONFIG_DIR="$(pwd)/crd-config"
# The Documents, Downloads and Desktop folders on the VM are synced to this folder
HOST_HOME_MAP="$(pwd)/vm-home"


# ***********************  AVOID EDITING BELOW THIS LINE ***********************


# Load optional local overrides.
if [ -f ./.env ]; then
    set -a
    source ./.env
    set +a
fi

# Persist (synthetic) machine ID to (optionally) keep connection to CRD between
# container rebuilds
HOST_MACHINE_ID="$HOST_CONFIG_DIR/machine-id"
# Essential for this to run on Apple Silicon
PLATFORM="linux/amd64"
