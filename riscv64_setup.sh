#!/bin/bash
# This script is intended to be run in the chroot environment 

set -euo pipefail
apt update
apt install linux-image-riscv64 u-boot-menu -y
apt install network-manager sudo vim less man-db bash-completion tasksel  systemd-timesyncd rsync  wget binutils -y
apt install  openssh-server net-tools htop usbutils git  build-essential linux-cpupower -y
tasksel install standard
apt install mc smartmontools git libsensors5 libsensors-dev lm-sensors cloud-guest-utils  -y

echo "Set Hostname to starfive"
echo "starfive" > /etc/hostname
#hostnamectl set-hostname starfive

#Fix waiting for resume device at boot
echo "RESUME=none" | sudo tee /etc/initramfs-tools/conf.d/resume
update-initramfs -u

systemctl enable resize-rootfs.service


# create a default user if not exists
if ! id -u debian >/dev/null 2>&1; then
    useradd -m -s /bin/bash debian
    echo "debian:debian" | chpasswd
    usermod -aG sudo debian
fi

apt install locales -y
sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=de_DE.UTF-8

#Copy DTB files for StarFive
kernel_version=$(ls /lib/modules | sort -V | tail -n1)
dtb_source="/usr/lib/linux-image-${kernel_version}/"
dtb_target="/boot/dtbs"
echo "Copying DTB files for kernel version: $kernel_version"
rm -rf "$dtb_target"
mkdir -p "$dtb_target"
mkdir -p "$dtb_target"/"$kernel_version"
cp -rv "${dtb_source}"/starfive  "$dtb_target"/"$kernel_version"