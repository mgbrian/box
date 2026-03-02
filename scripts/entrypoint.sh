#!/bin/bash
set -e

XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/runtime-$USER}

sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chown -R "$USER:$USER" "$XDG_RUNTIME_DIR" "/home/$USER/.config/chrome-remote-desktop"
sudo chmod 700 "$XDG_RUNTIME_DIR"
sudo find "$XDG_RUNTIME_DIR" -mindepth 1 -delete
sudo rm -rf "/tmp/pyxdg-runtime-dir-fallback-$USER"
sudo rm -f /tmp/.X*-lock /tmp/.X11-unix/X*

if ls /home/$USER/.config/chrome-remote-desktop/host#*.json 1> /dev/null 2>&1; then
  XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" /opt/google/chrome-remote-desktop/chrome-remote-desktop --start
fi

tail -f /dev/null
