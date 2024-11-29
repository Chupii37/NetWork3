#!/bin/bash

# Update package list, install curl and Docker
echo "Updating and installing packages..."
sudo apt update -y
sudo apt install -y curl docker.io

# Start and enable Docker
echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Check and create directory if it doesn't exist
[ ! -d "network3-docker" ] && mkdir network3-docker && echo "Directory 'network3-docker' created."

cd network3-docker

# Retrieve public IP
public_ip=$(curl -s ifconfig.me)
if [ -z "$public_ip" ]; then
    echo "Failed to retrieve public IP. Exiting."
    exit 1
fi

# Create Dockerfile
cat <<EOL > Dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y wget ufw tar nano sudo net-tools iproute2 procps
RUN wget https://network3.io/ubuntu-node-v2.1.0.tar && tar -xf ubuntu-node-v2.1.0.tar && rm ubuntu-node-v2.1.0.tar
WORKDIR /ubuntu-node
EXPOSE 8080
CMD ["bash", "-c", "bash manager.sh up; bash manager.sh key; exec bash"]
EOL

# Build and run Docker container
echo "Building and running the container..."
docker build -t network3-docker-image .
docker run -it --name network3-docker-container -p 8080:8080 network3-docker-image

# Final information
echo "Container is running on port 8080."
echo "To access the dashboard, visit: https://account.network3.ai/main?o=$public_ip:8080"
