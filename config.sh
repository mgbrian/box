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
# Load optional local overrides before applying defaults.
if [ -f ./.env ]; then
    set -a
    source ./.env
    set +a
fi
# Remote desktop user inside the container
CRD_USER="${CRD_USER:-crduser}"
# Remote desktop user's password inside the container
CRD_PASSWORD="${CRD_PASSWORD:-crdpassword}"
# Path to the folder containing persisted CRD config data
HOST_CONFIG_DIR="$(pwd)/crd-config"
# Path to the folder containing persisted home folder data
# The Documents, Downloads and Desktop folders on the VM are synced to this folder
HOST_HOME_MAP="$(pwd)/vm-home"

# Persist (synthetic) machine ID to (optionally) keep connection to CRD between
# container rebuilds
HOST_MACHINE_ID="$(pwd)/crd-config/machine-id"
# Essential for this to run on Apple Silicon
PLATFORM="linux/amd64"
