#!/bin/bash

# Stop all running containers
echo "Stopping all running containers..."
docker stop $(docker ps -aq)

# Remove all stopped containers
echo "Removing all stopped containers..."
docker rm $(docker ps -aq)

# Remove all unused images (both dangling and unreferenced)
echo "Removing all unused Docker images..."
docker image prune -a -f

# Remove all unused volumes
echo "Removing all unused Docker volumes..."
docker volume prune -f

echo "Docker cleanup complete!"