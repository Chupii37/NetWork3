#!/bin/bash

# Menampilkan pesan setelah logo
echo -e "\033[33mShowing Aniani!!!\033[0m"

# Menampilkan logo tanpa menyimpan file, langsung dari URL
echo -e "\033[32mMenampilkan logo...\033[0m"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash

# Warna untuk format output
INFO="\033[34m"
SUCCESS="\033[32m"
ERROR="\033[31m"
NC="\033[0m"  # Tanpa Warna
BANNER="\033[1;33m"

# Instalasi Docker
echo -e "${INFO}Memasang Docker...${NC}"
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
echo -e "${SUCCESS}Docker berhasil dipasang.${NC}"

# Memeriksa apakah direktori ada
if [ -d "network3-docker" ]; then
  echo -e "${INFO}Direktori network3-docker sudah ada.${NC}"
else
  # Membuat direktori
  mkdir network3-docker
  echo -e "${SUCCESS}Direktori network3-docker berhasil dibuat.${NC}"
fi

# Masuk ke dalam direktori
cd network3-docker

# Mengambil IP publik
public_ip=$(curl -s ifconfig.me)
if [ -z "$public_ip" ]; then
  echo -e "${ERROR}Gagal mengambil alamat IP publik. Keluar.${NC}"
  exit 1
fi

# Membuat atau mengganti Dockerfile dengan konten yang ditentukan
cat <<EOL > Dockerfile
# Menggunakan Ubuntu terbaru sebagai base image
FROM ubuntu:latest

# Instal wget, ufw, tar, nano, sudo, net-tools, iproute2, dan procps
RUN apt-get update && apt-get install -y \\
    wget \\
    ufw \\
    tar \\
    nano \\
    sudo \\
    net-tools \\
    iproute2 \\
    procps

# Mengunduh dan mengekstrak Network3 dari URL yang baru
RUN wget https://network3.io/ubuntu-node-v2.1.1.tar.gz && \\
    tar -xvzf ubuntu-node-v2.1.1.tar.gz && \\
    rm ubuntu-node-v2.1.1.tar.gz

# Masuk ke direktori ubuntu-node
WORKDIR /ubuntu-node

# Membuka port 8080
RUN ufw allow 8080

# Menjalankan node dan memberikan shell
CMD ["bash", "-c", "bash manager.sh up; bash manager.sh key; exec bash"]
EOL

# Mendeteksi instance network3-docker yang sudah ada dan menemukan nomor instance tertinggi
existing_instances=$(docker ps -a --filter "name=network3-docker-" --format "{{.Names}}" | grep -Eo 'network3-docker-[0-9]+' | grep -Eo '[0-9]+'$ | sort -n | tail -1)

# Menetapkan nomor instance
if [ -z "$existing_instances" ]; then
  instance_number=1
else
  instance_number=$((existing_instances + 1))
fi

# Menetapkan nama container
container_name="network3-docker-$instance_number"

# Menghitung nomor port
port_number=$((8080 + instance_number - 1))

# Membangun Docker image dengan nama yang ditentukan
docker build -t $container_name .

# Memeriksa apakah ufw terinstal dan menambahkan aturan untuk nomor port
if command -v ufw > /dev/null; then
  echo -e "${INFO}Mengonfigurasi UFW untuk mengizinkan lalu lintas di port $port_number...${NC}"
  sudo ufw allow $port_number
  echo -e "${SUCCESS}UFW berhasil dikonfigurasi.${NC}"
fi

# Menampilkan pesan penyelesaian dan perintah untuk melihat log
echo -e "${SUCCESS}Docker container akan dibangun dan dijalankan pada port $port_number.${NC}"
echo -e "${INFO}Untuk melihat dashboard, kunjungi:${NC}"
echo -e "${BANNER}https://account.network3.ai/main?o=$public_ip:$port_number${NC}"
echo -e "${INFO}Gunakan kunci yang akan ditampilkan untuk menghubungkan node dengan email Anda${NC}"

# Menjalankan Docker container dengan nama dinamis sesuai dengan container_name
docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --name $container_name -p $port_number:8080 $container_name
