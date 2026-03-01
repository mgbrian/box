#!/bin/bash

# -----------------------------------------------------------
# Script to run any additional setup, e.g. custom installs.
# This runs as the last step in the container build.
#
# *** Copy to scripts/custom-setup.sh and edit as needed. ***
#
# -----------------------------------------------------------

set -e
export DEBIAN_FRONTEND=noninteractive


# ************************  DO NOT EDIT ABOVE THIS LINE ************************


# 1. Install Nano
sudo apt-get update
sudo apt-get install -y nano

# 2. Install Brave
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update
sudo apt-get install -y brave-browser

# 3. Install Python 3.14
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.14 python3.14-venv python3.14-dev
# Set as default
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

# 4. Install Deno
curl -fsSL https://deno.land/install.sh | sh
# Inject path into .bashrc for future sessions
echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.bashrc
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.bashrc

# 5. Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rustup usually adds itself to .profile, but add explicitly to .bashrc
echo 'source "$HOME/.cargo/env"' >> ~/.bashrc
