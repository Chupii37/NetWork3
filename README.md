# Network3 Node

## System Requirements
CPU: 4
RAM: 6GB

## Register for a Network3 Account
Before running the node, you need to sign up for an account on Network3. You can sign up using the following link :

[Register on Network3](https://account.network3.ai/register_page?rc=43d8df25)

## Installation
Follow the steps below to install the necessary software:
1. Check if Port 8080 is Available
    ```bash
    sudo netstat -tuln | grep ':8080'
    ```
2. Update the System and Install curl
    ```bash
    sudo apt update
    sudo apt install curl
    ```
3. Run Network3 Node
    ```bash
    wget https://raw.githubusercontent.com/Chupii37/NetWork3/refs/heads/main/NetWork3.sh -O /tmp/NetWork3.sh && chmod +x /tmp/NetWork3.sh && sudo /tmp/NetWork3.sh
    ```



