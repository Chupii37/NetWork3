#!/bin/bash

# Menampilkan pesan setelah logo
echo -e "\033[33mShowing Aniani!!!\033[0m"

# Menampilkan logo tanpa menyimpan file, langsung dari URL
echo -e "\033[32mMenampilkan logo...\033[0m"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash

# Langkah 1: Memastikan Docker terinstal
echo -e "\033[34mMemeriksa apakah Docker sudah terinstal...\033[0m"
if ! command -v docker &> /dev/null; then
    echo -e "\033[31mDocker belum terinstal, menginstal Docker...\033[0m"
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo -e "\033[32mDocker sudah terinstal.\033[0m"
fi

# Langkah 2: Menginstal net-tools untuk pemeriksaan jaringan
echo -e "\033[34mMenginstal net-tools...\033[0m"
sudo apt install -y net-tools

# Langkah 3: Mengunduh file ubuntu-node-v2.1.1.tar.gz
echo -e "\033[34mMengunduh ubuntu-node-v2.1.1.tar.gz...\033[0m"
wget https://network3.io/ubuntu-node-v2.1.1.tar.gz

# Langkah 4: Mengekstrak file tar.gz yang diunduh
echo -e "\033[34mMengekstrak file tar.gz...\033[0m"
tar -xvzf ubuntu-node-v2.1.1.tar.gz

# Langkah 5: Masuk ke direktori ubuntu-node
cd ubuntu-node/ || exit

# Langkah 6: Mengubah izin agar manager.sh bisa dieksekusi
echo -e "\033[34mMengubah izin untuk manager.sh...\033[0m"
chmod +x manager.sh

# Langkah 7: Memastikan firewall aktif dan menambahkan aturan untuk membuka port 8080
echo -e "\033[34mMemastikan firewall aktif dan menambahkan aturan untuk membuka port 8080...\033[0m"

# Memeriksa apakah ufw (Uncomplicated Firewall) aktif
if ! sudo ufw status | grep -q "Status: active"; then
    echo -e "\033[33mFirewall belum aktif. Mengaktifkan firewall...\033[0m"
    sudo ufw enable
else
    echo -e "\033[32mFirewall sudah aktif.\033[0m"
fi

# Menambahkan aturan untuk membuka port 8080
sudo ufw allow 8080/tcp

# Langkah 8: Membangun Docker image
echo -e "\033[34mMembangun Docker image dengan nama 'ubuntu-node'...\033[0m"
sudo docker build -t ubuntu-node .

# Langkah 9: Menjalankan Docker container dengan port 8080 dan restart otomatis
echo -e "\033[34mMenjalankan Docker container dengan port 8080...\033[0m"
sudo docker run -d --name ubuntu-node-container -p 8080:8080 --restart=always ubuntu-node

# Langkah 10: Menjalankan manager.sh untuk memulai node di dalam container
# Menjalankan manager.sh hanya setelah kontainer berjalan
echo -e "\033[34mMenjalankan manager.sh untuk memulai node di dalam container...\033[0m"
sudo docker exec ubuntu-node-container /bin/bash -c "./manager.sh up"

# Langkah 11: Menjalankan manager.sh untuk menghasilkan key di dalam container
echo -e "\033[34mMenjalankan manager.sh untuk menghasilkan key di dalam container...\033[0m"
sudo docker exec ubuntu-node-container /bin/bash -c "./manager.sh key"

# Pesan akhir
echo -e "\033[32mKunci berhasil dihasilkan dan sistem siap. Skrip eksekusi selesai.\033[0m"
