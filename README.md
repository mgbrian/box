# Box

Setup for a local Linux virtual machine using Docker and Chrome Remote Desktop.

## Requirements

- An Apple Silicon Mac - The current setup has been finetuned for and tested on Apple Silicon, but should work on other environments with minimal tweaking. Review and update `config.sh`, `setup.sh` and `Dockerfile` as needed.
- Docker - On Apple Silicon, ensure "Use Rosetta for x86_64/amd64 emulation" enabled, as Google doesn't bundle CRD for ARM. In Docker Desktop, this is in Settings > General.
- A Google account to use Chrome Remote Desktop.

## Initial Setup

### 1. Set Script Permissions

Run this once to make all scripts executable:

```bash
chmod +x auth.sh cleanup.sh config.sh setup.sh start.sh stop.sh
```

### 2. Set Up Machine

Run the setup script. This will build the image and initiate the Chrome Remote Desktop auth flow.

    **NOTE: If a container has been created before, this will wipe any persisted data.**

```bash
./setup.sh
```

## Daily Usage

- **To stop:** `./stop.sh`
- **To start:** `./start.sh` (The container will remember your credentials and automatically appear online in CRD).
