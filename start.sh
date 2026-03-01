#!/bin/bash

source ./config.sh

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "--- Starting container ---"

    docker start $CONTAINER_NAME

else
    echo "--- Creating and running new container ---"

    mkdir -p "$HOST_CONFIG_DIR"
    mkdir -p "$HOST_HOME_MAP/Desktop"
    mkdir -p "$HOST_HOME_MAP/Documents"
    mkdir -p "$HOST_HOME_MAP/Downloads"

    docker run -d \
      --name $CONTAINER_NAME \
      --platform $PLATFORM \
      --hostname $CRD_HOSTNAME \
      --shm-size=2g \
      --security-opt seccomp=unconfined \
      -v "$HOST_CONFIG_DIR:/home/crduser/.config/chrome-remote-desktop" \
      -v "$HOST_HOME_MAP/Desktop:/home/crduser/Desktop" \
      -v "$HOST_HOME_MAP/Documents:/home/crduser/Documents" \
      -v "$HOST_HOME_MAP/Downloads:/home/crduser/Downloads" \
      $IMAGE_NAME
fi
