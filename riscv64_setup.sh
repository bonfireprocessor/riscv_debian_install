apt update
apt install linux-image-riscv64 u-boot-menu -y
apt install network-manager sudo vim less man-db bash-completion tasksel  systemd-timesyncd rsync  wget binutils -y
openssh-server net-tools htop usbutils git  build-essential linux-cpupower -y
tasksel install standard
apt install mc smartmontools -y

# create a default user
useradd -m -s /bin/bash debian
echo "debian:debian" | chpasswd
usermod -aG sudo debian