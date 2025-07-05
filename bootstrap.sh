#!/bin/bash
set -e

source "$(dirname "$0")/env.sh"
 
sudo mmdebstrap \
  --arch=riscv64 \
  --variant=standard \
  --include=ca-certificates,locales,dialog,netbase,ifupdown,systemd-sysv \
  trixie \
  $MOUNT_ROOT \
  http://deb.debian.org/debian


# Copy various configuration files and scripts
sudo cp -rv template/fstab $MOUNT_ROOT/etc/fstab
sudo cp -rv  template/resize-rootfs.sh $MOUNT_ROOT/usr/local/bin
sudo chmod +x $MOUNT_ROOT/usr/local/bin/resize-rootfs.sh
sudo cp -rv template/resize-rootfs.service $MOUNT_ROOT/etc/systemd/system
sudo cp -rv template/99-cpufreq.rules $MOUNT_ROOT/etc/udev/rules.d
sudo cp -rv template/u-boot $MOUNT_ROOT/etc/default



#Execute setup script in chroot environment
sudo systemd-nspawn --machine=starfive  -D $MOUNT_ROOT --bind riscv64_setup.sh:/setup.sh /setup.sh
# Old Version: Using chroot
#sudo cp riscv64_setup.sh $MOUNT_ROOT/tmp
#sudo chmod +x $MOUNT_ROOT/tmp/riscv64_setup.sh
#sudo chroot $MOUNT_ROOT /tmp/riscv64_setup.sh
#sudo rm $MOUNT_ROOT/tmp/riscv64_setup.sh

#Prepare EFI partition

sudo cp -rv $MOUNT_ROOT/boot/* $MOUNT_EFI/
sudo cp template/uEnv.txt $MOUNT_EFI/

