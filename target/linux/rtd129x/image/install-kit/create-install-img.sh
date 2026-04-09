#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Create install.img for RTD129x devices
# Based on official ARS2 firmware structure

set -e

INSTALL_KIT_DIR="$(dirname "$0")"
OUTPUT_DIR="${1:-$(pwd)/output}"
VERSION="${2:-custom-$(date +%Y%m%d)}"
MODEL="${3:-ars2}"

echo "=== RTD129x install.img Builder ==="
echo "Output: $OUTPUT_DIR"
echo "Version: $VERSION"
echo "Model: $MODEL"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check required files
if [ ! -f "$OUTPUT_DIR/kernel" ]; then
    echo "ERROR: kernel not found in $OUTPUT_DIR"
    echo "Please provide: kernel, rootfs.squashfs, dtb"
    exit 1
fi

# Get file sizes
KERNEL_SIZE=$(stat -c%s "$OUTPUT_DIR/kernel" 2>/dev/null || stat -f%z "$OUTPUT_DIR/kernel")
ROOTFS_SIZE=$(stat -c%s "$OUTPUT_DIR/rootfs.squashfs" 2>/dev/null || stat -f%z "$OUTPUT_DIR/rootfs.squashfs")
DTB_SIZE=$(stat -c%s "$OUTPUT_DIR/dtb" 2>/dev/null || stat -f%z "$OUTPUT_DIR/dtb")

echo "Kernel size: $KERNEL_SIZE bytes"
echo "Rootfs size: $ROOTFS_SIZE bytes"
echo "DTB size: $DTB_SIZE bytes"

# Create config.txt
cat > "$OUTPUT_DIR/config.txt" << EOF
# Package Information
company="OpenWrt Community"
description="OpenWrt for RTD129x"
modelname="${MODEL}"
version="${VERSION}"
releaseDate="$(date +%Y-%m-%d)"
signature=""
# Package Configuration
start_customer=y
verify=n
install_dtb=y
install_avfile_count=0
reboot_delay=5
efuse_key=0
efuse_fw=0
rpmb_fw=0
secure_boot=0
###
###   fw = (type file target)
fw = kernelDT rtd-129x.dtb 0x2100000
fw = linuxKernel emmc.Image 0x3000000
###
###   part = (name mount_point filesystem file size)
part = rootfs / squashfs rootfs.bin 134217728
EOF

# Create layout.txt
cat > "$OUTPUT_DIR/layout.txt" << EOF
#define CREATE_DATE " $(date +%b %d %Y) "
#define CREATE_TIME " $(date +%H:%M:%S) "
#define BOOTTYPE " BOOTTYPE_COMPLETE "
#define SSUWORKPART 0
#define BOOTPART 0
#define FW_KERNEL_DT " target=2100000 offset=b1ce00 size=$(printf '%x' $DTB_SIZE) type=bin name=rtd-129x.dtb "
#define FW_KERNEL " target=3000000 offset=b28e00 size=$(printf '%x' $KERNEL_SIZE) type=bin name=emmc.Image "
#define PART0 " offset=8000000 size=8000000 mount_point=/ mount_dev=/dev/block/mmcblk0p1 filesystem=squashfs partname=rootfs type=img name=rootfs.bin "
#define TAG 1
EOF

# Copy install_a
cp "$INSTALL_KIT_DIR/install_a" "$OUTPUT_DIR/install_a"
chmod +x "$OUTPUT_DIR/install_a"

# Rename files to match official naming
if [ -f "$OUTPUT_DIR/kernel" ]; then
    mv "$OUTPUT_DIR/kernel" "$OUTPUT_DIR/emmc.Image"
fi
if [ -f "$OUTPUT_DIR/rootfs.squashfs" ]; then
    mv "$OUTPUT_DIR/rootfs.squashfs" "$OUTPUT_DIR/rootfs.bin"
fi
if [ -f "$OUTPUT_DIR/dtb" ]; then
    mv "$OUTPUT_DIR/dtb" "$OUTPUT_DIR/rtd-129x.dtb"
fi

# Create minimal rescue files (empty placeholders for now)
if [ ! -f "$OUTPUT_DIR/rescue.Image" ]; then
    cp "$OUTPUT_DIR/emmc.Image" "$OUTPUT_DIR/rescue.Image"
fi
if [ ! -f "$OUTPUT_DIR/rescue.emmc.dtb" ]; then
    cp "$OUTPUT_DIR/rtd-129x.dtb" "$OUTPUT_DIR/rescue.emmc.dtb"
fi
if [ ! -f "$OUTPUT_DIR/rescue.dtb" ]; then
    cp "$OUTPUT_DIR/rtd-129x.dtb" "$OUTPUT_DIR/rescue.dtb"
fi

# Create minimal bootloader placeholder
mkdir -p "$OUTPUT_DIR/omv"
if [ ! -f "$OUTPUT_DIR/omv/bootloader.tar" ]; then
    # Create minimal bootloader tar
    touch "$OUTPUT_DIR/omv/fsbl.bin"
    touch "$OUTPUT_DIR/omv/hw_setting.bin"
    touch "$OUTPUT_DIR/omv/uboot.bin"
    tar -C "$OUTPUT_DIR/omv" -cf "$OUTPUT_DIR/omv/bootloader.tar" fsbl.bin hw_setting.bin uboot.bin
fi

# Create minimal mbr.bin (512 bytes)
if [ ! -f "$OUTPUT_DIR/mbr.bin" ]; then
    dd if=/dev/zero of="$OUTPUT_DIR/mbr.bin" bs=512 count=1 2>/dev/null
fi

# Create minimal fw_tbl.bin and gold_fw_tbl.bin
if [ ! -f "$OUTPUT_DIR/fw_tbl.bin" ]; then
    dd if=/dev/zero of="$OUTPUT_DIR/fw_tbl.bin" bs=512 count=1 2>/dev/null
fi
if [ ! -f "$OUTPUT_DIR/gold_fw_tbl.bin" ]; then
    dd if=/dev/zero of="$OUTPUT_DIR/gold_fw_tbl.bin" bs=512 count=1 2>/dev/null
fi

# Create minimal etc.bin (ext4 placeholder)
if [ ! -f "$OUTPUT_DIR/etc.bin" ]; then
    dd if=/dev/zero of="$OUTPUT_DIR/etc.bin" bs=1M count=128 2>/dev/null
fi

# Create minimal audio placeholder
if [ ! -f "$OUTPUT_DIR/bluecore.audio" ]; then
    dd if=/dev/zero of="$OUTPUT_DIR/bluecore.audio" bs=913328 count=1 2>/dev/null
fi
if [ ! -f "$OUTPUT_DIR/rescue.audio" ]; then
    cp "$OUTPUT_DIR/bluecore.audio" "$OUTPUT_DIR/rescue.audio"
fi

# Create rescue rootfs placeholder
if [ ! -f "$OUTPUT_DIR/rescue.root.emmc.cpio.gz_pad.img" ]; then
    dd if=/dev/zero of="$OUTPUT_DIR/rescue.root.emmc.cpio.gz_pad.img" bs=4194304 count=1 2>/dev/null
fi
if [ ! -f "$OUTPUT_DIR/rescue.cpio.gz" ]; then
    gzip -c /dev/null > "$OUTPUT_DIR/rescue.cpio.gz" 2>/dev/null || true
fi

# Create install.img
echo "Creating install.img..."
cd "$OUTPUT_DIR"
tar --owner=0 --group=0 --numeric-owner -cf "install.img" \
    bluecore.audio \
    config.txt \
    emmc.Image \
    etc.bin \
    fw_tbl.bin \
    gold_fw_tbl.bin \
    install_a \
    layout.txt \
    mbr.bin \
    omv \
    rescue.Image \
    rescue.audio \
    rescue.cpio.gz \
    rescue.dtb \
    rescue.emmc.dtb \
    rescue.root.emmc.cpio.gz_pad.img \
    rootfs.bin \
    rtd-129x.dtb

echo "=== Done ==="
echo "Created: $OUTPUT_DIR/install.img"
ls -la "$OUTPUT_DIR/install.img"