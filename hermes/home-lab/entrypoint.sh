#!/bin/bash
set -e

MARKER_FILE="$HOME/.hermes/.setup_finished"
TEMPLATE_DIR="/tmp/hermes_template"

if [ ! -f "$MARKER_FILE" ]; then
    echo "Checking for configurations..."
    
    # Check if directory is empty
    if [ -z "$(ls -A "$HOME/.hermes" 2>/dev/null)" ]; then
        echo "Empty volume detected. Populating with default hermes resources..."
        
        # -a preserves permissions, ownership, and symlinks
        cp -a "$TEMPLATE_DIR/." "$HOME/.hermes/"
        
        echo "🧹 Cleaning up internal setup templates..."
        rm -rf "$TEMPLATE_DIR"
    fi

    # --- THE SMART TOGGLE ---
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
        echo ""
        echo "👉 TO FIX, CLEAN UP AND RUN THE FOLLOWING COMMANDS:"
        echo "  docker compose down"
        echo "  docker compose run --service-ports hermes-dashboard"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        exit 1
    fi
fi

# Passes all arguments to the hermes command and replaces the shell process
exec hermes "$@"