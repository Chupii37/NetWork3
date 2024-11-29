#!/bin/bash

# Update and install Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Create directory if it doesn't exist
mkdir -p /home/$USER/network3-docker
cd /home/$USER/network3-docker

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

# Build Docker image
echo "Building the Docker image..."
docker build -t network3-docker-image .

# Set container name and port number (default values)
container_name="network3-docker-container"
port_number=8080

# Run Docker container with necessary privileges
echo "Starting the container with required privileges..."
docker run -it --cap-add=NET_ADMIN --device /dev/net/tun --name $container_name -p $port_number:8080 network3-docker-image

# Final information
echo "Container is running on port 8080."
echo "To access the dashboard, visit: https://account.network3.ai/main?o=$public_ip:8080"
