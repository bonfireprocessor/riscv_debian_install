#!/bin/bash
set -e

sudo apt update
sudo apt install mmdebstrap qemu-user-static binfmt-support systemd-container -y
#The line beelow is only neded when the created image is suppored to run in RISC-V QEMU
#it is used for script run_qemu.sh
sudo apt install qemu-system-misc qemu-utils opensbi u-boot-qemu libguestfs-tools -y
