# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

### Devices ###
define Device/Default
  PROFILES := Default
  KERNEL = kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb
  KERNEL_LOADADDR := 0x03000000
  IMAGES := sysupgrade.bin sysupgrade.tar
  IMAGE/sysupgrade.bin = append-kernel | pad-to 64k | append-rootfs | pad-rootfs | check-size | append-metadata
  IMAGE/sysupgrade.tar = sysupgrade-tar
  DEVICE_DTS_DIR = $$(DTS_DIR)/rtd129x
  DEVICE_DTS = $$(SOC)-$$(DEVICE_VARIANT)
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))