# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Felix (RTD1296 OpenWrt Porting)

define Device/rtd1295
  SOC := rtd1295
  KERNEL_LOADADDR := 0x03000000
endef

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
      kmod-mmc-overlay \
      blkid \
      blockdev
endef
TARGET_DEVICES += linkease_easepi-ars2

### Zidoo Z9S ###
define Device/zidoo_z9s
  $(Device/rtd1296)
  DEVICE_VENDOR := Zidoo
  DEVICE_MODEL := Z9S
  DEVICE_VARIANT := z9s
  DEVICE_PACKAGES := \
      kmod-r8169 \
      kmod-mmc-overlay \
      blkid \
      blockdev
endef
TARGET_DEVICES += zidoo_z9s

### Banana Pi BPI-W2 ###
define Device/bananapi_bpi-w2
  $(Device/rtd1296)
  DEVICE_VENDOR := Banana Pi
  DEVICE_MODEL := BPI-W2
  DEVICE_VARIANT := bpi-w2
  DEVICE_PACKAGES := \
      kmod-r8169 \
      kmod-mmc-overlay \
      blkid \
      blockdev
endef
TARGET_DEVICES += bananapi_bpi-w2
