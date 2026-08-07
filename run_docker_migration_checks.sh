#!/bin/bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-raspilot-ubuntu24-arm64-check}"

docker buildx build \
  --platform linux/arm64 \
  --load \
  -t "$IMAGE_NAME" \
  -f Dockerfile.ubuntu24-arm64 \
  .

docker run --rm --platform linux/arm64 "$IMAGE_NAME"
