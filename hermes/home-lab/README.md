To make it clear that this is a **local-first, home-use tool**, we should pivot the language from "Production-Ready" (which implies high availability, load balancers, and public exposure) to words like **"Self-Hosted,"** **"Local Environment,"** and **"Personal Dashboard."**

Here is the adjusted README.

***

# 🚀 Hermes Home Dashboard

`ghcr.io/esuminski/hermes-home`

A specialized, self-hosted Docker image designed to run the **Hermes Dashboard** as a local home server. It provides a persistent, controlled environment for your Hermes agent, managing your configuration and workspace automatically.

**Note:** This image is intended for **local home network use**. It is optimized for ease of setup in a personal environment rather than for high-availability public web deployment.

## ✨ Features

- **Automatic Initialization**: Automatically populates your local config directory on the first run.
- **Persistent Identity**: Separates your agent's identity (auth/settings) from your actual work (workspace).
- **Smart Entrypoint**: Detects if a terminal is available for the one-time interactive setup or fails gracefully with instructions if running in headless mode.
- **Pre-configured Environment**: Comes pre-loaded with essential tools for a smooth experience (`git`, `ffmpeg`, `python`, etc.).

---

## 🛠️ Quick Start

### 1. Prepare your Environment
Create an `.env` file in your project directory to define your local storage paths and dashboard credentials:

```env
# Local Storage Paths (Relative or Absolute)
HERMES_CONFIG_DIR=./hermes_config
HERMES_WORKSPACE_DIR=./hermes_workspace

# Local Dashboard Security
DASHBOARD_USER=admin
DASHBOARD_PASS=your_secure_password_here
```

### 2. Initial Setup (Required)
Because the first run requires you to interactively complete the `hermes setup` (to link your accounts locally), you **cannot** simply use `docker compose up`. You must run the service in an interactive terminal first.

**Run this command:**
```bash
docker compose run --service-ports hermes-dashboard
```

Follow the on-screen prompts in your terminal to complete the Hermes configuration. Once you see `✅ Setup complete`, you can exit.

### 3. Normal Operation
Once the setup is complete, you can start the dashboard in the background as a local service:

```bash
docker compose up -d
```

The dashboard will be available on your local network at `http://localhost:9119`.

---

## 📂 Volume Architecture

This image uses two distinct volumes to ensure your configuration is never lost even if you clear your workspace:

| Mount Point | Host Variable | Purpose |
| :--- | :--- | :--- |
| `/root/.hermes` | `${HERMES_CONFIG_DIR}` | **Identity & Config**: Stores your `.setup_finished` marker, authentication tokens, and agent settings. |
| `/workspace` | `${HERMES_WORKSPACE_DIR}` | **Project Files**: The local directory where your files and generated projects reside. |

---

## ⚠️ Troubleshooting

### "❌ ERROR: INTERACTIVE SETUP REQUIRED"
If you see this error, it means the container detected that the configuration files are missing, but you are running in "headless" mode (e.g., via `docker compose up`).

**The Fix:**
The `hermes setup` command requires a TTY (a terminal) to accept your input. Run the following to fix it:
```bash
docker compose down
docker compose run --service-ports hermes-dashboard
```

### Permission Denied on Volumes
If you are running on Linux or WSL and encounter permission issues, ensure the local directories exist before running the container:
```bash
mkdir -p ./hermes_config ./hermes_workspace
```

---

## 🐳 Docker Compose Template
```yaml
services:
  hermes-dashboard:
    image: ghcr.io/esuminski/hermes-home
    container_name: hermes-dashboard
    ports:
      - "9119:9119"
    volumes:
      - ${HERMES_CONFIG_DIR}:/root/.hermes
      - ${HERMES_WORKSPACE_DIR}:/workspace
    environment:
      - HERMES_DASHBOARD_BASIC_AUTH_USERNAME=${DASHBOARD_USER}
      - HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=${DASHBOARD_PASS}
```