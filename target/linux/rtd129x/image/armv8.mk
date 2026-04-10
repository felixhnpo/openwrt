# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Felix (RTD1296 OpenWrt Porting)

define Device/rtd1296
  SOC := rtd1296
  KERNEL_LOADADDR := 0x03000000
  IMAGE_SIZE := 524288k
endef

### EasePi ARS2 ###
define Device/linkease_easepi-ars2
  $(Device/rtd1296)
  DEVICE_VENDOR := LinkEase
  DEVICE_MODEL := EasePi ARS2
  DEVICE_VARIANT := ars2
  SUPPORTED_DEVICES += linkease,easepi-ars2 realtek,rtd-1296
  DEVICE_PACKAGES := \
      kmod-r8169soc \
      kmod-gpio-rtd129x \
      kmod-leds-gpio \
      kmod-input-gpio-keys \
      kmod-gpio-button-hotplug \
      blkid \
      blockdev
endef
TARGET_DEVICES += linkease_easepi-ars2
