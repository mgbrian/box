# Box

A lightweight Linux VM using Docker and Chrome Remote Desktop -- essentially a full-featured machine with a graphical interface and persistent storage.

## Requirements

- Apple Silicon Mac - The current setup assumes Apple Silicon, but should work on other environments with minimal tweaking. Review and update `config.sh`, `setup.sh` and `Dockerfile` as needed.
- Docker - On Apple Silicon, ensure "Use Rosetta for x86_64/amd64 emulation" enabled, as Google doesn't bundle CRD for ARM. In Docker Desktop, this is under Settings > General.
- A Google account to use Chrome Remote Desktop.

## Initial Setup

### 1. Prepare Scripts

#### Set Permissions

Run this once to make all scripts executable:

```bash
chmod +x auth.sh cleanup.sh config.sh setup.sh start.sh stop.sh
```

#### [Optional] Override Default Credentials

You can create a `.env` file in the project root to override `CRD_USER`, and `CRD_PASSWORD`. If omitted, the defaults in `config.sh` are used.

```bash
cp sample_env .env
```

#### [Optional] Add Custom Additional/Setup Instructions

You may add any custom setup instructions e.g. software installs, etc. to `scripts/custom-setup.sh`.

```bash
cp scripts/custom-setup-sample.sh scripts/custom-setup.sh
```

Edit as needed before moving to step 2.

### 2. Set Up Machine

Run the setup script. This will build the image and initiate the Chrome Remote Desktop auth flow.

**NOTE: This will delete all persisted data from any previously created container.**

```bash
./setup.sh
```

## Daily Usage

Stop the machine:

```bash
./stop.sh
```

Start the machine (it will remember your credentials and appear online in CRD):

```bash
./start.sh
```

Rebuild the image while preserving machine identity and persisted home data:

```bash
./setup.sh
```

Rebuild and reset the machine identity only:

```bash
./setup.sh --reset-identity
```

Rebuild and delete persisted home data only:

```bash
./setup.sh --delete-data
```

Create a fully fresh machine (reset identity and delete persisted home data):

```bash
./setup.sh --new
```
