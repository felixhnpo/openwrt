# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

BOARD:=rtd129x
BOARDNAME:=Realtek RTD129x
FEATURES:=ext4 audio usb usbgadget gpio fpu pcie sata nvme rootfs-part boot-part squashfs
SUBTARGETS:=armv8

KERNEL_PATCHVER:=6.12

define Target/Description
	Build firmware image for Realtek RTD1295/RTD1296 NAS SoC devices.
endef

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += \
	uboot-envtools \
	partx-utils \
	e2fsprogs \
	mkf2fs \
	kmod-gpio-button-hotplug \
	kmod-r8169 \
	blkid \
	blockdev \
	kmod-sound-rtk-hwdep \
	kmod-mmc-overlay

KERNELNAME:=Image dtbs

$(eval $(call BuildTarget))
