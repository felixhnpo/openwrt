# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Felix (RTD1296 OpenWrt Porting)

RTD129X_MENU:=RTD129x Kernel modules

define KernelPackage/r8169soc
  SUBMENU:=$(RTD129X_MENU)
  TITLE:=Realtek RTD129x SoC Gigabit Ethernet driver
  DEPENDS:=@TARGET_rtd129x +kmod-phylib
  KCONFIG:=CONFIG_R8169SOC=y
  FILES:=$(LINUX_DIR)/drivers/net/ethernet/realtek/r8169soc.ko
  AUTOLOAD:=$(call AutoProbe,r8169soc)
endef

define KernelPackage/r8169soc/description
  This package contains the Realtek RTD129x SoC Gigabit Ethernet driver.
endef

$(eval $(call KernelPackage,r8169soc))

define KernelPackage/gpio-rtd129x
  SUBMENU:=$(RTD129X_MENU)
  TITLE:=Realtek RTD129x GPIO driver
  DEPENDS:=@TARGET_rtd129x +kmod-gpio
  KCONFIG:=CONFIG_GPIO_RTD129x=y
  FILES:=$(LINUX_DIR)/drivers/gpio/gpio-rtd129x.ko
  AUTOLOAD:=$(call AutoProbe,gpio-rtd129x)
endef

define KernelPackage/gpio-rtd129x/description
  This package contains the Realtek RTD129x GPIO driver.
endef

$(eval $(call KernelPackage,gpio-rtd129x))
