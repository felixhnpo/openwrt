# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Felix (RTD1296 OpenWrt Porting)

define Device/rtd1296
  SOC := rtd1296
  KERNEL_LOADADDR := 0x03000000
endef

### EasePi ARS2 ###
define Device/linkease_easepi-ars2
  $(Device/rtd1296)
  DEVICE_VENDOR := LinkEase
  DEVICE_MODEL := EasePi ARS2
  DEVICE_VARIANT := ars2
  DEVICE_PACKAGES := \
      kmod-r8169 \
      blkid \
      blockdev
endef
TARGET_DEVICES += linkease_easepi-ars2
