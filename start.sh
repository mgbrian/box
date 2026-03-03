#!/bin/bash

source ./config.sh

mkdir -p "$HOST_CONFIG_DIR"

# Generate  Machine ID once if it doesn't exist
if [ ! -f "$PERSISTED_MACHINE_ID_FILE" ]; then
    echo "Generating new Machine ID..."
    dbus-uuidgen > "$PERSISTED_MACHINE_ID_FILE"
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
      -e XDG_RUNTIME_DIR="/tmp/runtime-$CRD_USER" \
      -v "$HOST_CONFIG_DIR:/home/$CRD_USER/.config/chrome-remote-desktop" \
      -v "$PERSISTED_MACHINE_ID_FILE:/var/lib/dbus/machine-id:ro" \
      -v "$PERSISTED_MACHINE_ID_FILE:/etc/machine-id:ro" \
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
    # Check for the CRD host process using -f (full command line match)
    # Also check if the X11 socket for display :20 exists
    if docker exec $CONTAINER_NAME pgrep -f "chrome-remote-desktop-host" > /dev/null 2>&1 || \
       docker exec $CONTAINER_NAME test -S /tmp/.X11-unix/X20; then
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
