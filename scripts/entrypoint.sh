#!/bin/bash
set -e

# Expand a literal "$USER" if present (Docker ENV won't expand).
# If the env var isn’t set, default to /tmp/runtime-$USER (as provided via Docker ENV)
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/runtime-$USER}
# If the value still contains the literal text $USER
# (might happen when passing /tmp/runtime-$USER through Docker env without shell expansion),
# replace that literal with the actual username at runtime
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR//\$USER/$USER}

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
