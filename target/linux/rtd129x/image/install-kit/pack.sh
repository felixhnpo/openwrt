#!/bin/bash
# Pack install.img for RTD129x (Official SDK Method)
set -e

SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="$1"
VERSION="${2:-custom-$(date +%Y%m%d)}"

if [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: pack.sh <output_dir>"
    exit 1
fi

cd "$OUTPUT_DIR"

# Generate config.txt
echo "# Package Information" > config.txt
echo "company=\"OpenWrt Community\"" >> config.txt
echo "description=\"OpenWrt for RTD129x - EasePi ARS2\"" >> config.txt
echo "modelname=\"ars2\"" >> config.txt
echo "version=\"$VERSION\"" >> config.txt
echo "releaseDate=\"$(date +%Y-%m-%d)\"" >> config.txt
echo "signature=\"\"" >> config.txt
echo "# Package Configuration" >> config.txt
echo "start_customer=y" >> config.txt
echo "verify=n" >> config.txt
echo "install_dtb=y" >> config.txt
echo "install_avfile_count=0" >> config.txt
echo "reboot_delay=5" >> config.txt
echo "efuse_key=0" >> config.txt
echo "efuse_fw=0" >> config.txt
echo "rpmb_fw=0" >> config.txt
echo "secure_boot=0" >> config.txt
echo "###" >> config.txt
echo "###   fw = (type file target)" >> config.txt
echo "fw = kernelDT rtd-129x.dtb 0x2100000" >> config.txt
echo "fw = linuxKernel emmc.Image 0x3000000" >> config.txt
echo "###" >> config.txt
echo "###   part = (name mount_point filesystem file size)" >> config.txt
echo "part = rootfs / squashfs rootfs.bin 134217728" >> config.txt

# Copy official components from install-kit
cp "$SCRIPT_DIR/install_a" . 2>/dev/null || echo "Warning: install_a not found"
cp "$SCRIPT_DIR/bluecore.audio" . 2>/dev/null || true
cp "$SCRIPT_DIR/mbr.bin" . 2>/dev/null || true
cp "$SCRIPT_DIR/fw_tbl.bin" . 2>/dev/null || true
cp "$SCRIPT_DIR/gold_fw_tbl.bin" . 2>/dev/null || true
cp "$SCRIPT_DIR/etc.bin" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.Image" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.audio" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.cpio.gz" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.dtb" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.emmc.dtb" . 2>/dev/null || true
cp "$SCRIPT_DIR/rescue.root.emmc.cpio.gz_pad.img" . 2>/dev/null || true

# Copy bootloader
mkdir -p omv
cp "$SCRIPT_DIR/omv/bootloader.tar" omv/ 2>/dev/null || true

# Generate layout.txt based on file sizes
KERNEL_SIZE=$(stat -f%z emmc.Image 2>/dev/null || stat -c%s emmc.Image)
DTB_SIZE=$(stat -f%z rtd-129x.dtb 2>/dev/null || stat -c%s rtd-129x.dtb 2>/dev/null || echo 49086)
echo "#define CREATE_DATE \" $(date +%b %d %Y) \" > layout.txt
echo "#define CREATE_TIME \" $(date +%H:%M:%S) \" >> layout.txt
echo "#define BOOTTYPE \" BOOTTYPE_COMPLETE \" >> layout.txt
echo "#define FW_KERNEL_DT \" target=2100000 offset=b1ce00 size=$(printf %x $DTB_SIZE) type=bin name=rtd-129x.dtb \" >> layout.txt
echo "#define FW_KERNEL \" target=3000000 offset=b28e00 size=$(printf %x $KERNEL_SIZE) type=bin name=emmc.Image \" >> layout.txt
echo "#define PART0 \" offset=8000000 size=8000000 mount_point=/ filesystem=squashfs partname=rootfs type=img name=rootfs.bin \" >> layout.txt
echo "#define TAG 1" >> layout.txt

# Create install.img
echo "Creating install.img..."
tar --owner=0 --group=0 --numeric-owner -cf install.img \
    bluecore.audio config.txt emmc.Image etc.bin fw_tbl.bin gold_fw_tbl.bin \
    install_a layout.txt mbr.bin omv rescue.Image rescue.audio rescue.cpio.gz \
    rescue.dtb rescue.emmc.dtb rescue.root.emmc.cpio.gz_pad.img rootfs.bin rtd-129x.dtb 2>/dev/null || \
tar --owner=0 --group=0 --numeric-owner -cf install.img config.txt install_a layout.txt emmc.Image rootfs.bin

echo "Created: install.img"
ls -la install.img
