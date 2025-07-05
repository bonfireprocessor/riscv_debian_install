#!/bin/bash
set -e

sudo apt update
sudo apt install mmdebstrap qemu-user-static binfmt-support systemd-container qemu-system-misc qemu-utils opensbi u-boot-qemu libguestfs-tools -y
