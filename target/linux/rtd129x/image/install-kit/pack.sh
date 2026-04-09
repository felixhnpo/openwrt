#!/bin/bash
# Pack install.img for RTD129x (Official ARS2 format)
set -e

SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="$1"
VERSION="${2:-21.02.3-custom}"

if [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: pack.sh <output_dir>"
    exit 1
fi

cd "$OUTPUT_DIR"

# Get file sizes for layout.txt
KERNEL_SIZE=$(stat -f%z emmc.Image 2>/dev/null || stat -c%s emmc.Image)
ROOTFS_SIZE=$(stat -f%z rootfs.bin 2>/dev/null || stat -c%s rootfs.bin)
DTB_SIZE=$(stat -f%z rtd-129x.dtb 2>/dev/null || stat -c%s rtd-129x.dtb || echo 49086)

# Generate config.txt (Official ARS2 format)
cat > config.txt << "EOF"
# Package Information
company=""
description=""
modelname=""
version=""
releaseDate=""
signature=""
# Package Configuration
start_customer=y
verify=y
install_dtb=y
install_avfile_count=0
reboot_delay=5
efuse_key=0
efuse_fw=0
rpmb_fw=0
secure_boot=0
###
###   fw = (type file target)
fw = rescueDT rescue.emmc.dtb 0x2140000
fw = rescueRootFS rescue.root.emmc.cpio.gz_pad.img 0x30000000
fw = audioKernel bluecore.audio 0x1b00000
fw = kernelDT rtd-129x.dtb 0x2100000
fw = linuxKernel emmc.Image 0x3000000
###
###   part = (name mount_point filesystem file size)
part = rootfs / squashfs rootfs.bin 134217728
part = etc etc ext4 etc.bin 7381975040
EOF

# Generate layout.txt (simplified version)
# Note: For proper offset calculation, use rtd129x_img_gen tool
KERNEL_SIZE_HEX=$(printf "%x" $KERNEL_SIZE)
DTB_SIZE_HEX=$(printf "%x" $DTB_SIZE)

cat > layout.txt << "EOF"
#define CREATE_DATE "$(date +%b %d %Y)"
#define CREATE_TIME "$(date +%H:%M:%S)"
#define BOOTTYPE " BOOTTYPE_COMPLETE "
#define SSUWORKPART 0
#define BOOTPART 0
#define FW_KERNEL_DT " target=2100000 offset=b1ce00 size=$DTB_SIZE_HEX type=bin name=rtd-129x.dtb "
#define FW_KERNEL " target=3000000 offset=b28e00 size=$KERNEL_SIZE_HEX type=bin name=emmc.Image "
#define PART0 " offset=8000000 size=8000000 mount_point=/ mount_dev=/dev/block/mmcblk0p1 filesystem=squashfs partname=rootfs type=img name=rootfs.bin "
#define TAG 1
EOF

# Copy official components from install-kit
cp "$SCRIPT_DIR/install_a" . 2>/dev/null || echo "Warning: install_a not found"
cp "$SCRIPT_DIR/bluecore.audio" . 2>/dev/null || true
cp "$SCRIPT_DIR/bluecore.audio.slim" bluecore.audio 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.emmc.dtb" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.root.emmc.cpio.gz_pad.img" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.Image" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.dtb" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.cpio.gz" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.audio" . 2>/dev/null || true

# Copy bootloader
mkdir -p omv
cp "$SCRIPT_DIR/omv/bootloader.tar" omv/ 2>/dev/null || true

# Create other required files
if [ ! -f etc.bin ]; then
    echo "RESET000" | dd bs=512 count=1 conv=sync > etc.bin 2>/dev/null
fi
if [ ! -f fw_tbl.bin ]; then
    dd if=/dev/zero of=fw_tbl.bin bs=496 count=1 2>/dev/null
fi
if [ ! -f gold_fw_tbl.bin ]; then
    dd if=/dev/zero of=gold_fw_tbl.bin bs=288 count=1 2>/dev/null
fi
if [ ! -f mbr.bin ]; then
    dd if=/dev/zero of=mbr.bin bs=512 count=1 2>/dev/null
fi

# Create install.img
echo "Creating install.img..."
tar --owner=0 --group=0 --numeric-owner -cf install.img \
    bluecore.audio config.txt emmc.Image etc.bin fw_tbl.bin gold_fw_tbl.bin \
    install_a layout.txt mbr.bin omv rescue.Image rescue.audio rescue.cpio.gz \
    rescue.dtb rescue.emmc.dtb rescue.root.emmc.cpio.gz_pad.img rootfs.bin rtd-129x.dtb

echo "Created: install.img"
ls -la install.img
