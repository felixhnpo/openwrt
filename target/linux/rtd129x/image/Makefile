# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

# Custom install.img build step
define Build/install-img
	mkdir -p $(KDIR)/install-output
	cp $(IMAGE_KERNEL) $(KDIR)/install-output/kernel
	cp $(IMAGE_ROOTFS) $(KDIR)/install-output/rootfs.squashfs
	cp $(DTS_DIR)/rtd129x/$(firstword $(DEVICE_DTS)).dtb $(KDIR)/install-output/dtb
	$(TARGET_DIR)/../linux-rtd129x/image/install-kit/create-install-img.sh $(KDIR)/install-output $(DEVICE_MODEL)
	mv $(KDIR)/install-output/install.img $@
endef

### Devices ###
define Device/Default
  PROFILES := Default
  KERNEL = kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb
  KERNEL_LOADADDR := 0x03000000
  IMAGES := sysupgrade.bin sysupgrade.tar install.img
  IMAGE/sysupgrade.bin = append-kernel | pad-to 64k | append-rootfs | pad-rootfs | check-size | append-metadata
  IMAGE/sysupgrade.tar = sysupgrade-tar
  IMAGE/install.img = install-img
  DEVICE_DTS_DIR = $$(DTS_DIR)/rtd129x
  DEVICE_DTS = $$(SOC)-$$(DEVICE_VARIANT)
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))