#!/bin/bash

source ./config.sh

# Check if the container is actually running
if [ -z "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Container '$CONTAINER_NAME' is already stopped."
    exit 0
fi

echo "Initiating graceful shutdown..."

# Stop CRD
docker exec -u "$CRD_USER" $CONTAINER_NAME /opt/google/chrome-remote-desktop/chrome-remote-desktop --stop > /dev/null 2>&1 || true

# Kill audio daemons so restart starts from a clean runtime state.
docker exec $CONTAINER_NAME pkill -u "$CRD_USER" -x pulseaudio > /dev/null 2>&1 || true
docker exec $CONTAINER_NAME pkill -u "$CRD_USER" -x pipewire > /dev/null 2>&1 || true
docker exec $CONTAINER_NAME pkill -u "$CRD_USER" -x wireplumber > /dev/null 2>&1 || true

# Terminate XFCE, the X server, and any leftover helper shells.
docker exec $CONTAINER_NAME pkill -15 -u $CRD_USER > /dev/null 2>&1 || true

# Polling loop for timeout
TIMEOUT=15
ELAPSED=0
SHUTDOWN_SUCCESS=false

echo -n "Waiting for services to spin down..."

while [ $ELAPSED -lt $TIMEOUT ]; do
    # Wait until the CRD host, display server, and audio daemons are all gone.
    if ! docker exec $CONTAINER_NAME pgrep -u "$CRD_USER" -f "chrome-remote-desktop-host|Xorg|Xvfb|pipewire|wireplumber|pulseaudio" > /dev/null 2>&1; then
        SHUTDOWN_SUCCESS=true
        break
    fi
    sleep 1
    echo -n "."
    ELAPSED=$((ELAPSED + 1))
done

echo ""

# Handle the result
if [ "$SHUTDOWN_SUCCESS" = true ]; then
    # Clear session runtime artifacts so the next docker start gets a clean CRD launch.
    docker exec $CONTAINER_NAME bash -lc "rm -rf /tmp/runtime-$CRD_USER/* /tmp/runtime-root/* /tmp/pyxdg-runtime-dir-fallback-$CRD_USER && rmdir /tmp/runtime-root 2>/dev/null || true; rm -f /tmp/.X20-lock /tmp/.X11-unix/X20" > /dev/null 2>&1 || true

    echo "Services stopped gracefully."
    docker stop $CONTAINER_NAME > /dev/null
    echo "Machine stopped cleanly."
else
    echo "[!] Graceful shutdown timed out after $TIMEOUT seconds."
    read -p "Force stop? (y/N): " FORCE

    if [[ "$FORCE" =~ ^[Yy]$ ]]; then
        docker stop -t 0 $CONTAINER_NAME > /dev/null
        echo "Force stopped."
    fi
fi
