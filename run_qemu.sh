#!/bin/bash
# run_qemu.sh - Script to start QEMU for riscv_debian_install
# Author: Thomas Hornschuh
# Date: 2024-06-09
# Description: This script starts a QEMU instance for RISC-V Debian.

set -e
set -u

source "$(dirname "$0")/env.sh"
ROOT_PARTITION="/dev/vda4"  # root partition in the disk image

echo "Starting QEMU with disk image: $IMAGE"

# Prüfe, ob das IMAGE als Loop-Device gemountet ist
if /usr/sbin/losetup | grep -q $IMAGE; then
    echo "Error: The disk image $IMAGE is mounted as a loop device. Please unmount with run/umountfs.sh it and try again."
    exit 1
fi

if [ ! -f "$IMAGE" ]; then
    echo "Disk image $IMAGE not found!"
    exit 1
fi

# qemu-system-riscv64 -nographic -machine virt -smp 4  -m 1.0G \
#  -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
#  -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf \
#  -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-device,rng=rng0 \
#  -drive file=$IMAGE,format=raw,if=virtio \
#  -device virtio-net-device,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::22222-:22

qemu-system-riscv64 -nographic -machine virt -smp 4  -m 1.0G \
 -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf \
 -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-device,rng=rng0 \
 -drive file=$IMAGE,format=raw,if=virtio \
 -device virtio-net-device,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::22222-:22