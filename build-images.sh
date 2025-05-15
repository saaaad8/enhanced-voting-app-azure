#!/bin/bash

# Script to build all Docker images for the voting app
# Usage: ./build-images.sh [tag]
# If no tag is provided, 'latest' will be used

# Set default tag if not provided
TAG=${1:-latest}

# Print information
echo "Building all images with tag: $TAG"

# Check if we should use minikube's docker daemon
if command -v minikube &> /dev/null; then
  if minikube status &> /dev/null; then
    echo "Minikube detected and running. Setting up Docker environment..."
    eval $(minikube docker-env)
    MINIKUBE_ACTIVE=true
    echo "Now building images directly in Minikube's Docker daemon"
  fi
fi

# Build the vote app
echo "Building vote image..."
docker build -t voting-app-vote:$TAG ./vote
if [ $? -ne 0 ]; then
  echo "Error building vote image"
  exit 1
fi

# Build the result app
echo "Building result image..."
docker build -t voting-app-result:$TAG ./result
if [ $? -ne 0 ]; then
  echo "Error building result image"
  exit 1
fi

# Build the worker app
echo "Building worker image..."
docker build -t voting-app-worker:$TAG ./worker
if [ $? -ne 0 ]; then
  echo "Error building worker image"
  exit 1
fi

# Check if seed-data has a Dockerfile and build it if it does
if [ -f "./seed-data/Dockerfile" ]; then
  echo "Building seed-data image..."
  docker build -t voting-app-seed:$TAG ./seed-data
  if [ $? -ne 0 ]; then
    echo "Error building seed-data image"
    exit 1
  fi
fi

echo "All images built successfully with tag: $TAG"

if [ "$MINIKUBE_ACTIVE" = true ]; then
  echo "Images are now available in Minikube's Docker daemon"
  echo "You can deploy the application with: kubectl apply -f k8s-specifications/"
else
  echo "To make these images available to Minikube, you can either:"
  echo "1. Rebuild with Minikube's Docker daemon: eval \$(minikube docker-env) && ./build-images.sh"
  echo "2. Push to a registry and update deployment files to use that registry"
fi
