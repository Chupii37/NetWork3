# Network3 Node

## System Requirements
CPU: 4
RAM: 6GB

## Register for a Network3 Account
Before running the node, you need to sign up for an account on Network3. You can sign up using the following link :

[Register on Network3](https://account.network3.ai/register_page?rc=43d8df25)

## Installation
Follow the steps below to install the necessary software:
1. Update the System and Install curl
    ```bash
    sudo apt update
    sudo apt install curl
    ```
2. Run Network3 Node
    ```bash
    wget https://raw.githubusercontent.com/Chupii37/Network3-Node/refs/heads/main/network3.sh -O network3.sh && chmod +x network3.sh && ./network3.sh
    ```

You can access the dashboard by opening https://account.network3.ai/main?o=xx.xx.xx.xx:8080

Replace XX.XX.XX.XX with your server IP

Paste the modified link into your browser's address bar.

Then you could click the '+' button on the top-right of the panel of current node in the dashboard. And input the private key of the node in the dialog to bind.

## After End Of Project
Stop the Docker Container
```bash
docker stop network3-docker
 ```

Remove the Docker Container
```bash
docker rm network3-docker
 ```

Remove the Docker Image
```bash
docker rmi network3-docker
 ```
Remove Folder
```bash
rm -rf network3-docker
```

## Want to See More Cool Projects?

Buy me a coffee so I can stay awake and make more cool stuff (and less bugs)! I’ll be forever grateful and a little bit jittery. 😆☕ 

[Buy me a coffee](https://paypal.me/chupii37 )

