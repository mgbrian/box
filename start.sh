#!/bin/bash

source ./config.sh

mkdir -p "$HOST_CONFIG_DIR"

# Generate  Machine ID once if it doesn't exist
if [ ! -f "$HOST_MACHINE_ID" ]; then
    echo "Generating new Machine ID..."
    dbus-uuidgen > "$HOST_MACHINE_ID"
fi

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
      -v "$HOST_CONFIG_DIR:/home/$CRD_USER/.config/chrome-remote-desktop" \
      -v "$HOST_MACHINE_ID:/var/lib/dbus/machine-id:ro" \
      -v "$HOST_MACHINE_ID:/etc/machine-id:ro" \
      -v "$HOST_HOME_MAP/Desktop:/home/$CRD_USER/Desktop" \
      -v "$HOST_HOME_MAP/Documents:/home/$CRD_USER/Documents" \
      -v "$HOST_HOME_MAP/Downloads:/home/$CRD_USER/Downloads" \
      $IMAGE_NAME
fi

# Boot completion confirmation...

echo -n "Waiting for Remote Desktop to boot..."

# Poll every 2 seconds for up to 30 seconds
TIMEOUT=30
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
    # Check if the Xvfb virtual display process is running inside the container
    if docker exec $CONTAINER_NAME pgrep -x "Xvfb" > /dev/null 2>&1; then
        echo " Ready!"
        echo "--------------------------------------------------------"
        echo "Machine '$CRD_HOSTNAME' is ONLINE."
        echo "Connect here: https://remotedesktop.google.com/access"
        echo "--------------------------------------------------------"
        exit 0
    fi
    sleep 2
    echo -n "."
    ELAPSED=$((ELAPSED + 2))
done

echo " Timed out."
echo "The container started, but the display server took too long."
echo "Run 'docker logs $CONTAINER_NAME' to check for errors."
