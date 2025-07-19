#!/bin/bash
set -e

mkdir -p mnt/bootfs mnt/rootfs
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

sgdisk -o $IMAGE \
    -n 1:4096:8191    -c 1:"spl"   -t=1:2e54b353-1271-4842-806f-e436d6af6985 \
    -n 2:8192:16383   -c 2:"uboot" -t=2:5b193300-fc78-40cd-8002-e86c45580b47  \
    -n 3:16384:630783 -c 3:"ESP"   -t 3:ef00 \
    -n 4:630784:0     -c 4:"root"  -t 4:8300

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
cat > run/umountfs.sh <<EOF
#!/bin/bash
if mount | grep -q "${LOOPDEV}p3"; then
    sudo umount "${LOOPDEV}p3"
fi
sudo umount $MOUNT_ROOT
sudo losetup -d $LOOPDEV
EOF

chmod +x run/umountfs.sh

echo
echo "  To unmount and detach, run:"
echo "    ./run/umountfs.sh"

