#!/bin/bash
set -e

source "$(dirname "$0")/env.sh"

# Sanity checks

if mountpoint -q "$MOUNT_EFI" || mountpoint -q "$MOUNT_ROOT"; then
    echo "Image already mounted, please run ./run/cleanfs.sh first"
    exit 1
fi

if [ -f "$IMAGE" ]; then
    read -p "File $IMAGE already exists. Overwrite? (y/N): " answer
    case "$answer" in
        [Yy]* )
            rm -f "$IMAGE"
            ;;
        * )
            echo "Aborted."
            exit 1
            ;;
    esac
fi

# Create a 4GB empty image file
dd if=/dev/zero of=$IMAGE bs=1M count=4096

# 2. Partition the image using GPT
parted $IMAGE --script mklabel gpt \
  mkpart BBL 4096s 8191s \
  mkpart FSBL 8192s 16383s \
  mkpart ESP fat32 16384s 630783s \
  set 3 esp on \
  mkpart root ext4 630784s 100%

# Set up loop device with partition scanning
LOOPDEV=$(sudo losetup --find --partscan --show $IMAGE)

# Create file systems
sudo mkfs.vfat -F 32 "${LOOPDEV}p3"     # EFI system partition
sudo mkfs.ext4 "${LOOPDEV}p4"          # Root filesystem

# Mount the partitions
sudo mkdir -p $MOUNT_EFI
sudo mkdir -p $MOUNT_ROOT

sudo mount "${LOOPDEV}p3" $MOUNT_EFI
sudo mount "${LOOPDEV}p4" $MOUNT_ROOT

# Output information
echo "   Image successfully created and partitions mounted:"
echo "  - EFI partition mounted at: $MOUNT_EFI"
echo "  - Root (ext4) partition mounted at: $MOUNT_ROOT"
echo "  - Loop device in use: $LOOPDEV"

# Create run directory if it doesn't exist
mkdir -p run

# Write cleanup commands to run/cleanfs.sh
cat > run/cleanfs.sh <<EOF
#!/bin/bash
sudo umount $MOUNT_EFI
sudo umount $MOUNT_ROOT
sudo losetup -d $LOOPDEV
EOF

chmod +x run/cleanfs.sh

echo
echo "  To unmount and detach, run:"
echo "    ./run/cleanfs.sh"

