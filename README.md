Full-featured Linux VM with a graphical interface and persistent storage, using Docker and Chrome Remote Desktop.

## Requirements

- Apple Silicon Mac - The current setup assumes Apple Silicon, but should work on other environments with minimal tweaking. Review and update `config.sh`, `setup.sh` and `Dockerfile` as needed.
- Docker - On Apple Silicon, ensure "Use Rosetta for x86_64/amd64 emulation" enabled, as Google doesn't bundle CRD for ARM. In Docker Desktop, this is under Settings > General.
- A Google account to use Chrome Remote Desktop.

## Initial Setup

### Easy Setup

If you don't need to customise the setup process, run this, follow the instructions in the terminal, and you're done!

```bash
chmod +x *.sh && ./setup.sh
```

**Good to know:**

- The default VM username and password are `crduser` and `crdpassword`.
- If you've previously set up a machine (from the same folder), this will preserve VM data (in the Desktop, Downloads and Documents folders), and not require re-authentication with Chrome Remote Desktop.

Skip to [Daily Usage](#daily-usage).

### Detailed Setup

For more control of the setup process:

#### 1. Prepare Scripts

##### Set Permissions

Run this once to make all scripts executable:

```bash
chmod +x auth.sh cleanup.sh config.sh setup.sh start.sh stop.sh
```

##### [Optional] Override Default Credentials

You can create a `.env` file in the project root to override `CRD_USER`, and `CRD_PASSWORD`. If omitted, the defaults in `config.sh` are used.

```bash
cp sample_env .env
```

##### [Optional] Add Custom Setup Instructions

You may add any custom setup instructions e.g. software installs, etc. to `scripts/custom-setup.sh`.

Duplicate and edit the sample script before moving to step 2:

```bash
cp scripts/custom-setup-sample.sh scripts/custom-setup.sh
```

#### 2. Set Up Machine

Run the setup script. This will build the image and initiate the Chrome Remote Desktop auth flow.

**NOTE: If a previous container existed, this will preserve the CRD identity and persisted home folder data. See section below for how to perform a hard(er) reset.**

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

Rebuild the image while preserving machine identity (existing link to CRD) and persisted home data:

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

Create a fully fresh machine (reset identity/sever existing link to CRD and delete persisted home data):

```bash
./setup.sh --new
```
