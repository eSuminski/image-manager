
#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <container-name> <image-name>"
    exit 1
fi

CONTAINER_NAME="$1"
IMAGE_NAME="$2"
VOLUME_NAME="${CONTAINER_NAME}-data"

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "✗ Container '$CONTAINER_NAME' already exists"
    echo "  Remove it with: docker rm $CONTAINER_NAME"
    echo "  Or use a different name"
    exit 1
fi

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo "✗ Image '$IMAGE_NAME' does not exist"
    echo "  List available images with: docker images"
    exit 1
fi

ERROR_OUTPUT=$(docker run -d \
    --network host \
    --name "$CONTAINER_NAME" \
    -v "$VOLUME_NAME:/home/devuser/project" \
    "$IMAGE_NAME" 2>&1)

if [ $? -eq 0 ]; then
    echo "✓ Container '$CONTAINER_NAME' started with volume '$VOLUME_NAME' using image '$IMAGE_NAME'"
else
    echo "✗ Failed to start container:"
    echo "$ERROR_OUTPUT"
    exit 1
fi