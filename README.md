# Box

A lightweight Linux VM using Docker and Chrome Remote Desktop -- essentially a full-featured machine with a graphical interface and persistent storage.

## Requirements

- Apple Silicon Mac - The current setup assumes Apple Silicon, but should work on other environments with minimal tweaking. Review and update `config.sh`, `setup.sh` and `Dockerfile` as needed.
- Docker - On Apple Silicon, ensure "Use Rosetta for x86_64/amd64 emulation" enabled, as Google doesn't bundle CRD for ARM. In Docker Desktop, this is under Settings > General.
- A Google account to use Chrome Remote Desktop.

## Initial Setup

### 1. Set Script Permissions

Run this once to make all scripts executable:

```bash
chmod +x auth.sh cleanup.sh config.sh setup.sh start.sh stop.sh
```

### 2. Set Up Machine

Run the setup script. This will build the image and initiate the Chrome Remote Desktop auth flow.

**NOTE: This will delete all persisted data from any previously created container.**

```bash
./setup.sh
```

## Daily Usage

- **To stop:** `./stop.sh`
- **To start:** `./start.sh` (The container will remember your credentials and automatically appear online in CRD).
- **To factory reset:** `./setup.sh` (This deletes any persisted data and builds a fresh machine).
