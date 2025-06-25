#!/bin/bash
set -e

MOUNT_ROOT=mnt/rootfs
MOUNT_EFI=mnt/sdcard

sudo mmdebstrap \
  --arch=riscv64 \
  --variant=standard \
  --include=ca-certificates,locales,dialog,netbase,ifupdown,systemd-sysv \
  trixie \
  $MOUNT_ROOT \
  http://deb.debian.org/debian

#Execute setup script in chroot environment
sudo cp riscv64_setup.sh $MOUNT_ROOT/tmp
sudo chmod +x $MOUNT_ROOT/tmp/riscv64_setup.sh
sudo chroot $MOUNT_ROOT /tmp/riscv64_setup.sh
sudo rm $MOUNT_ROOT/tmp/riscv64_setup.sh

#Prepare EFI partition

sudo cp -rv $MOUNT_ROOT/boot/* $MOUNT_EFI/
sudo cp template/uEnv.txt $MOUNT_EFI/

