#!/bin/bash

source ./config.sh

# Check if the container is actually running
if ! docker ps -q -f name=^/${CONTAINER_NAME}$ > /dev/null; then
    echo "Container '$CONTAINER_NAME' is already stopped."
    exit 0
fi

echo "Initiating graceful shutdown..."

# Stop CRD
docker exec $CONTAINER_NAME su - $CRD_USER -c "/opt/google/chrome-remote-desktop/chrome-remote-desktop --stop" > /dev/null 2>&1

# Kill Audio (both PulseAudio and PipeWire wrappers in 24.04)
docker exec $CONTAINER_NAME su - $CRD_USER -c "pkill -u $CRD_USER pulseaudio || pkill -u $CRD_USER pipewire" > /dev/null 2>&1 || true

# Terminate XFCE and the X Server
docker exec $CONTAINER_NAME pkill -15 -u $CRD_USER > /dev/null 2>&1 || true

# Polling loop for timeout
TIMEOUT=15
ELAPSED=0
SHUTDOWN_SUCCESS=false

echo -n "Waiting for services to spin down..."

while [ $ELAPSED -lt $TIMEOUT ]; do
    # Check if the main CRD host process OR the Xvfb server is still alive
    if ! docker exec $CONTAINER_NAME pgrep -f "chrome-remote-desktop-host|Xvfb" > /dev/null 2>&1; then
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
    # EXTRA STEP FOR 24.04: Force clear the X11 lock file if it still exists
    # This prevents the "Display :20 already in use" error on restart
    docker exec $CONTAINER_NAME rm -f /tmp/.X20-lock > /dev/null 2>&1

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
