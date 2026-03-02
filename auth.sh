#!/bin/bash

set -e
source ./config.sh

# Ensure the container is running before we exec into it
./start.sh

echo "--- Auth Setup ---"
echo "1. Visit: https://remotedesktop.google.com/headless"
echo "2. Click through the screens until you see an 'Authorise' button. Click on it."
echo "3. Copy the 'Debian Linux' command and paste it here:"
read -p "> " AUTH_COMMAND

if [[ $AUTH_COMMAND == *"start-host"* ]]; then
    docker exec -u "$CRD_USER" -it $CONTAINER_NAME bash -c "$AUTH_COMMAND"
    echo "Auth successful! Restarting container to apply audio/runtime config..."
    docker stop $CONTAINER_NAME > /dev/null 2>&1 || true
    ./start.sh
else
    echo "Error: Invalid command entered."
    exit 1
fi
