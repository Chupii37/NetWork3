#!/bin/bash

# Colors for output formatting
INFO="\033[34m"       # Blue for info messages
SUCCESS="\033[32m"    # Green for success messages
ERROR="\033[31m"      # Red for error messages
WARN="\033[33m"       # Yellow for warnings
NC="\033[0m"          # No color (reset to default)
BANNER="\033[1;33m"   # Bold Yellow for important banners or messages
CYAN="\033[36m"       # Cyan for informational output
MAGENTA="\033[35m"    # Magenta for special outputs
WHITE="\033[97m"      # White for additional uses

# Displaying a message after logo
echo -e "${BANNER}Displaying Aniani!!!${NC}"

# Display logo directly from URL
echo -e "${CYAN}Displaying logo...${NC}"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash

# Check if Docker is installed
echo -e "${INFO}Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${ERROR}Docker not found. Installing Docker...${NC}"
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    echo -e "${SUCCESS}Docker successfully installed.${NC}"

    # Clean up unnecessary packages
    echo -e "${INFO}Cleaning up unnecessary packages...${NC}"
    sudo apt-get remove --purge -y docker.io
    sudo apt-get autoremove -y
    sudo apt-get clean
    echo -e "${SUCCESS}Unnecessary packages removed.${NC}"

else
    echo -e "${SUCCESS}Docker is already installed.${NC}"
fi

# Check if the directory exists
if [ -d "network3-docker" ]; then
  echo -e "${INFO}Directory 'network3-docker' already exists.${NC}"
else
  # Create the directory
  mkdir network3-docker
  echo -e "${SUCCESS}Directory 'network3-docker' created successfully.${NC}"
fi

# Change to the directory
cd network3-docker

# Get public IP
public_ip=$(curl -s ifconfig.me)
if [ -z "$public_ip" ]; then
  echo -e "${ERROR}Failed to retrieve public IP address. Exiting.${NC}"
  exit 1
fi

# Create or update Dockerfile with the specified content
cat <<EOL > Dockerfile
# Using the latest Ubuntu as the base image
FROM ubuntu:latest

# Install wget, ufw, tar, nano, sudo, net-tools, iproute2, and procps
RUN apt-get update && apt-get install -y \\
    wget \\
    ufw \\
    tar \\
    nano \\
    sudo \\
    net-tools \\
    iproute2 \\
    procps

# Download and extract Network3 from the latest URL
RUN wget https://network3.io/ubuntu-node-v2.1.1.tar.gz && \\
    tar -xvzf ubuntu-node-v2.1.1.tar.gz && \\
    rm ubuntu-node-v2.1.1.tar.gz

# Set the working directory to /ubuntu-node
WORKDIR /ubuntu-node

# Open port 8080
RUN ufw allow 8080

# Run the node and provide a shell
CMD ["bash", "-c", "bash manager.sh up; bash manager.sh key; exec bash"]
EOL

# Set static container name
container_name="network3-docker"

# Set port number
port_number=8080

# Build the Docker image with the specified name
docker build -t $container_name .

# Check if ufw is installed and add firewall rule for the port
if command -v ufw > /dev/null; then
  echo -e "${INFO}Configuring UFW to allow traffic on port $port_number...${NC}"
  sudo ufw allow $port_number
  echo -e "${SUCCESS}UFW configured successfully.${NC}"
fi

# Display completion message and instructions
echo -e "${SUCCESS}Docker container will be built and run on port $port_number.${NC}"
echo -e "${WARN}Please make sure to allow the port through your firewall if UFW is not used.${NC}"
echo -e "${INFO}To view the dashboard, visit:${NC}"
echo -e "${BANNER}https://account.network3.ai/main?o=$public_ip:$port_number${NC}"
echo -e "${INFO}Use the key displayed to connect the node with your email${NC}"

# Run Docker container in detached mode (background)
docker run -it --cap-add=NET_ADMIN --device /dev/net/tun --name $container_name -p $port_number:8080 --restart unless-stopped $container_name
