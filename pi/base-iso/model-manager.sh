#!/bin/bash
# This script lives in base-iso/

# Get the directory where THIS script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ENV_FILE="${SCRIPT_DIR}/.env"
TEMPLATE_FILE="${SCRIPT_DIR}/models.json.template"
FINAL_FILE="${SCRIPT_DIR}/models.json"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found in $SCRIPT_DIR"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Template file not found in $SCRIPT_DIR"
    exit 1
fi

echo "📝 [Model Manager] Injecting variables from .env into $FINAL_FILE..."

# 1. Create a fresh copy of the template
cp "$TEMPLATE_FILE" "$FINAL_FILE"

# 2. Loop through the .env file and replace placeholders
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] || [ -z "$key" ] && continue
    
    # Clean up whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    [ -z "$key" ] && continue

    echo "   -> Mapping {{${key}}} -> ${value}"
    
    # Use | as delimiter to safely handle URLs with slashes
    sed -i "s|{{${key}}}|${value}|g" "$FINAL_FILE"

done < "$ENV_FILE"

echo "✅ [Model Manager] Configuration synchronization complete."