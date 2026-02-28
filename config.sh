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
# Path to the folder containing persisted data
HOST_CONFIG_DIR="$(pwd)/crd-config"

# Essential for this to run on Apple Silicon
PLATFORM="linux/amd64"
