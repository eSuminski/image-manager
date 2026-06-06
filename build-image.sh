#!/bin/bash

# --- Load Global Configuration ---
CONFIG_FILE="build.env"

if [ -f "$CONFIG_FILE" ]; then
    # Source the config. We use 'source' so the associative array is loaded.
    source "$CONFIG_FILE"
else
    echo "❌ Error: Global config file '$CONFIG_FILE' not found!"
    exit 1
fi

# --- Argument Parsing ---
if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory_name> [--full]"
    exit 1
fi

DIR_NAME=$1
FULL_BUILD=false
if [[ "$*" == *"--full"* ]]; then FULL_BUILD=true; fi

# Verify directory
if [ ! -d "$DIR_NAME" ]; then
    echo "❌ Error: Directory '$DIR_NAME' not found!"
    exit 1
fi

# --- Step 1: Component-Specific Preparation (Generic) ---
# Look up if there is a preparation script assigned to this directory
# We use an indirect reference to the associative array
PREP_SCRIPT="${PREP_SCRIPTS[$DIR_NAME]}"

if [ -n "$PREP_SCRIPT" ]; then
    if [ -f "$PREP_SCRIPT" ]; then
        echo "🔍 Detected component-specific setup. Invoking: $PREP_SCRIPT"
        bash "$PREP_SCRIPT"
        if [ $? -ne 0 ]; then
            echo "❌ Preparation failed. Aborting build."
            exit 1
        fi
    else
        echo "⚠️  Warning: Config mapped to '$PREP_SCRIPT' but file was not found."
    fi
fi

# --- Step 2: Standard Docker Build Logic ---
TAG_NAME="${REGISTRY_PREFIX}/${DIR_NAME}:latest"

if [ "$FULL_BUILD" = true ]; then
    echo "🚀 Starting MULTI-ARCH build and PUSH to $TAG_NAME..."
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t "$TAG_NAME" \
        "$DIR_NAME" \
        --push
else
    echo "🛠️ Starting Local build for $TAG_NAME..."
    docker build \
        -t "$TAG_NAME" \
        "$DIR_NAME" \
        --load
fi

echo "🏁 Process finished."