#!/bin/bash
set +x

PART=$(findmnt -n -o SOURCE /) || exit 1
DISK=$(echo "$PART" | sed -E 's|p?[0-9]+$||')

echo "Root partition: $PART"
echo "Corresponding device: $DISK"

# Expand root partition
PART_NUM=$(echo "$PART" | grep -o '[0-9]\+$')
GROWPART_OUTPUT=$(growpart "$DISK" "$PART_NUM" 2>&1)

echo "$GROWPART_OUTPUT" | grep -q "NOCHANGE"
if [ $? -eq 0 ]; then
    echo "No change in partition size, skipping resize2fs and gdisk."
else
    resize2fs "$PART" || exit 1
    sgdisk -e $DISK || exit 1
fi

if [[ "$DISK" =~ ^/dev/vd ]]; then
    echo "Skipping systemctl for virtio device ($DISK)."
else
    systemctl disable resize-rootfs.service
fi