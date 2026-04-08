# SPDX-License-Identifier: GPL-2.0-only

ARCH:=aarch64
SUBTARGET:=armv8
BOARDNAME:=RTD1295/RTD1296 boards (64 bit)

define Target/Description
	Build firmware image for Realtek RTD1295/RTD1296 devices.
	This firmware features a 64 bit kernel.
endef
