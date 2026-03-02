#!/bin/bash

source ./config.sh

# Check if the container is actually running
if ! docker ps -q -f name=^/${CONTAINER_NAME}$ > /dev/null; then
    echo "Container '$CONTAINER_NAME' is already stopped."
    exit 0
fi

echo "Initiating graceful shutdown of Remote Desktop services..."

# Stop CRD and PulseAudio cleanly
docker exec $CONTAINER_NAME su - "$CRD_USER" -c "/opt/google/chrome-remote-desktop/chrome-remote-desktop --stop" > /dev/null 2>&1
docker exec $CONTAINER_NAME su - "$CRD_USER" -c "pulseaudio -k" > /dev/null 2>&1 || true

# ell the XFCE desktop environment to terminate
docker exec $CONTAINER_NAME pkill -15 -f xfce > /dev/null 2>&1 || true

# Polling loop for timeout
TIMEOUT=15
ELAPSED=0
SHUTDOWN_SUCCESS=false

echo -n "Waiting for services to spin down..."

while [ $ELAPSED -lt $TIMEOUT ]; do
    # Check if the main CRD host process is still alive
    if ! docker exec $CONTAINER_NAME pgrep -f "chrome-remote-desktop-host" > /dev/null 2>&1; then
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
    echo "Services stopped gracefully. Shutting down container..."
    docker stop $CONTAINER_NAME > /dev/null
    echo "Machine stopped cleanly."
else
    echo "[!] Graceful shutdown timed out after $TIMEOUT seconds."
    read -p "Would you like to force stop the container? (y/N): " FORCE

    if [[ "$FORCE" =~ ^[Yy]$ ]]; then
        echo "Force stopping container..."
        # Using -t 0 tells Docker to skip the SIGTERM wait and just kill it instantly
        docker stop -t 0 $CONTAINER_NAME > /dev/null
        echo "Machine force stopped."
    else
        echo "Shutdown aborted. Container is still running."
    fi
fi
