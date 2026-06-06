#!/bin/bash

# --- Load Configuration ---
CONFIG_FILE="build.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Error: Configuration file '$CONFIG_FILE' not found!"
    exit 1
fi

# --- Argument Parsing ---
if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory_name> [--full]"
    exit 1
fi

DIR_NAME=$1

# Allow the user to override the config via the --full flag
if [[ "$*" == *"--full"* ]] || [ "$FULL_BUILD_ENABLED" = true ]; then
    FULL_BUILD=true
else
    FULL_BUILD=false
fi

# --- Step 1: Component-Specific Preparation ---
if [ "$DIR_NAME" == "base-iso" ]; then
    # Use the mapping from our config file
    PREP_SCRIPT="${PREP_SCRIPTS[$DIR_NAME]}"
    
    if [ -n "$PREP_SCRIPT" ] && [ -f "$PREP_SCRIPT" ]; then
        echo "🔍 Detected base-iso. Invoking Model Manager..."
        bash "$PREP_SCRIPT"
        if [ $? -ne 0 ]; then
            echo "❌ Preparation failed. Aborting build."
            exit 1
        fi
    fi
fi

# --- Step 2: Docker Build Logic ---
TAG_NAME="${REGISTRY_PREFIX}/${DIR_NAME}:latest"

if [ "$FULL_BUILD" = true ]; then
    echo "🚀 Starting MULTI-ARCH build and PUSH to $TAG_NAME..."
    docker buildx build --platform linux/amd64,linux/arm64 -t "$TAG_NAME" "$DIR_NAME" --push
else
    echo "🛠️ Starting Local build for $TAG_NAME..."
    docker build -t "$TAG_NAME" "$DIR_NAME" --load
fi

echo "🏁 Process finished."