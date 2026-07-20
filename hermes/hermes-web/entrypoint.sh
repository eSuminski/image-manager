#!/bin/bash
set -e

MARKER_FILE="$HOME/.hermes/.setup_finished"
TEMPLATE_DIR="/tmp/hermes_template"

# 1. HANDLE HERMES AGENT SETUP (Your existing logic)
if [ ! -f "$MARKER_FILE" ]; then
    echo "Checking for configurations..."
    if [ -z "$(ls -A "$HOME/.hermes" 2>/dev/null)" ]; then
        echo "Empty volume detected. Populating with default hermes resources..."
        cp -a "$TEMPLATE_DIR/." "$HOME/.hermes/"
        echo "🧹 Cleaning up internal setup templates..."
        rm -rf "$TEMPLATE_DIR"
    fi

    if [ -t 0 ]; then
        echo "----------------------------------------------------------"
        echo "🚀 FIRST TIME SETUP (INTERACTIVE MODE)"
        echo "----------------------------------------------------------"
        hermes setup
        touch "$MARKER_FILE"
        echo "✅ Setup complete"
        echo "----------------------------------------------------------"
    else
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "❌ ERROR: INTERACTIVE SETUP REQUIRED"
        echo "No terminal (TTY) detected. The 'hermes setup' command"
        echo "requires user input to complete configuration."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        exit 1
    fi
fi

# 2. HAND OFF TO THE COMMAND
# "$@" contains the CMD from your Dockerfile: 
# ["python3", "/opt/hermes-webui/bootstrap.py", "--host", "0.0.0.0", "--port", "9119", "--foreground"]

echo "Starting requested service: $@"

# Using 'exec' is vital. It replaces this bash script with the Python process.
# This ensures PID 1 is the Web UI, allowing it to receive signals (like SIGTERM)
# and ensuring 'docker logs' works perfectly.
exec "$@"