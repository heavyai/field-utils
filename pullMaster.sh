#!/bin/bash

# Define variables
REPOSITORY_URL="docker-internal.mapd.com/mapd"
IMAGE_NAME="mapd-render"
IMAGE_TAG="master"  # Assuming you want the latest image
SAVED_IMAGE_NAME="master_$(date +%m%d).tar.gz"

# Step 1: Pull the latest image from the internal repository
docker pull ${REPOSITORY_URL}/${IMAGE_NAME}:${IMAGE_TAG}

# Step 2: Save the Docker image to a tar file
#docker save -o ${SAVED_IMAGE_NAME} ${REPOSITORY_URL}/${IMAGE_NAME}:${IMAGE_TAG}
docker save ${REPOSITORY_URL}/${IMAGE_NAME}:${IMAGE_TAG} | gzip > ${SAVED_IMAGE_NAME}

echo "Image saved as ${SAVED_IMAGE_NAME}"
