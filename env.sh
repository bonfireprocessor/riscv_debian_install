export IMAGE="${IMAGE:-$(realpath run/sdcard.img)}"
export MOUNT_EFI="${MOUNT_EFI:-$(realpath mnt/bootfs)}"
export MOUNT_ROOT="${MOUNT_ROOT:-$(realpath mnt/rootfs)}"
export LOOPDEV="${LOOPDEV:-}"