#!/bin/bash
# This script is intended to be run in the chroot environment 

set -euo pipefail
apt update
apt install linux-image-riscv64 u-boot-menu -y
apt install network-manager sudo vim less man-db bash-completion tasksel  systemd-timesyncd rsync  wget binutils -y
apt install  openssh-server net-tools htop usbutils git  build-essential linux-cpupower -y
tasksel install standard
apt install mc smartmontools git libsensors5 libsensors-dev lm-sensors cloud-guest-utils gdisk   -y

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
sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

#Copy DTB files for StarFive
#This is only a fallback mechanism,normally u-boot-update (executed when installalling 
#linux-image-riscv64 and u-boot-menu) should copy the DTB files
kernel_version=$(ls /lib/modules | sort -V | tail -n1)
dtb_source="/usr/lib/linux-image-${kernel_version}/"
dtb_target="/boot/dtbs"
if [ -d "$dtb_target/$kernel_version" ]; then
    echo "DTB files for kernel version $kernel_version already exist, skipping copy."
else
    echo "DTB files for kernel version $kernel_version do not exist, copying..."
    rm -rf "$dtb_target"
    mkdir -p "$dtb_target"
    mkdir -p "$dtb_target"/"$kernel_version"
    cp -rv "${dtb_source}"/starfive  "$dtb_target"/"$kernel_version"
fi



# Because updating the U-Boot confiugration and the boot partition is not reliable currently, we disable automatic updates of the kernel.
# This is a workaround until the issue is resolved. 
# You can later remove the hold with: sudo apt-mark unhold linux-image-riscv64
apt-mark hold linux-image-riscv64