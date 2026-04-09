# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

# Build install.img using external script
define Build/install-img
	mkdir -p $(KDIR)/install-output
	cp $(IMAGE_KERNEL) $(KDIR)/install-output/emmc.Image
	cp $(IMAGE_ROOTFS) $(KDIR)/install-output/rootfs.bin
	$(TOPDIR)/target/linux/rtd129x/image/install-kit/pack.sh $(KDIR)/install-output
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
  DEVICE_DTS = rtd1296-ars2
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
