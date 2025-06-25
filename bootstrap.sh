#!/bin/bash
set -e

MOUNT_ROOT=mnt/rootfs

sudo mmdebstrap \
  --arch=riscv64 \
  --variant=standard \
  --include=ca-certificates,locales,dialog,netbase,ifupdown,systemd-sysv \
  trixie \
  $MOUNT_ROOT \
  http://deb.debian.org/debian