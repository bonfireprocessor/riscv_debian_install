#!/bin/bash
set -e

source "$(dirname "$0")/env.sh"

# Sanity checks

if mountpoint -q "$MOUNT_EFI" || mountpoint -q "$MOUNT_ROOT"; then
    echo "Image already mounted, please run ./run/cleanfs.sh first"
    exit 1
fi

# Set up loop device with partition scanning
LOOPDEV=$(sudo losetup --find --partscan --show $IMAGE)

# Mount the partitions
sudo mkdir -p $MOUNT_EFI
sudo mkdir -p $MOUNT_ROOT
sudo mount "${LOOPDEV}p3" $MOUNT_EFI
sudo mount "${LOOPDEV}p4" $MOUNT_ROOT

echo "  - EFI partition mounted at: $MOUNT_EFI"
echo "  - Root (ext4) partition mounted at: $MOUNT_ROOT"
echo "  - Loop device in use: $LOOPDEV"

# Write cleanup commands to run/cleanfs.sh
cat > run/umountfs.sh <<EOF
#!/bin/bash
sudo umount $MOUNT_EFI
sudo umount $MOUNT_ROOT
sudo losetup -d $LOOPDEV
EOF

chmod +x run/umountfs.sh

echo
echo "  To unmount and detach, run:"
echo "    ./run/umountfs.sh"
