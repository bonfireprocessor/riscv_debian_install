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
if mount | grep -q $$MOUNT_ROOT; then
    echo "Error: The disk image $IMAGE is mounted as a loop device. Please unmount it and try again."
    exit 1
fi

if [ ! -f "$IMAGE" ]; then
    echo "Disk image $IMAGE not found!"
    exit 1
fi

qemu-system-riscv64 -nographic -machine virt -smp 4  -m 1.0G \
 -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
 -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf \
 -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-device,rng=rng0 \
 -append "console=ttyS0 rw root=${ROOT_PARTITION}" \
 -device virtio-blk-device,drive=hd0 -drive file=$IMAGE,format=raw,id=hd0 \
 -device virtio-net-device,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::22222-:22

# Füge einen SD-Bus hinzu, damit die sd-card funktioniert
# Beispiel: -device sdhci-pci
# (QEMU emuliert einen SD-Host-Controller, an den die sd-card angeschlossen wird)
# Die sd-card wird dann als /dev/mmcblk0 im Gast erscheinen

# Beispiel für den SD-Bus:
# -device sdhci-pci

# In deinem QEMU-Aufruf ergänze:
# -device sdhci-pci

# Beispiel:
# qemu-system-riscv64 ... -device sdhci-pci -device sd-card,drive=hd0 -drive file="${IMAGE}",format=raw,id=hd0 ...
# Nein, das ist mit virtio-blk-device nicht möglich. Virtio-Blöckgeräte erscheinen im Gast immer als /dev/vdX.
# Wenn du ein Gerät als mmc0 (/dev/mmcblk0) haben möchtest, musst du stattdessen ein virtuelles SD/MMC-Gerät emulieren:
# Beispiel:
# -device sd-card,drive=hd0

# Die Zeile mit virtio-blk-device und -drive entfernst du und ersetzt sie durch:
# -device sd-card,drive=hd0 -drive file="${DISK_IMAGE}",format=raw,id=hd0

# Beachte, dass die Performance und Features von sd-card geringer sind als bei virtio-blk.