# SPDX-License-Identifier: GPL-2.0-only

PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

platform_check_image() {
	local board=$(board_name)
	local magic="$(get_magic_long "$1")"

	echo "platform_check_image"
	echo "board: $board"
	echo "image: $1"
	echo "magic: $magic"

	# Accept standard OpenWrt sysupgrade images
	# Magic numbers:
	# 27051956 - uImage
	# 73797375 - squashfs
	# 28cd3d45 - ignore (legacy)

	case "$magic" in
		"27051956")
			echo "uImage detected"
			return 0
			;;
		"73797375")
			echo "squashfs detected"
			return 0
			;;
		"28cd3d45")
			echo "Legacy image format, ignoring"
			return 1
			;;
	esac

	# Check for gzip compressed image
	local magic_gzip="$(get_magic_word "$1")"
	case "$magic_gzip" in
		"1f8b")
			echo "gzip compressed image detected"
			return 0
			;;
	esac

	# Check if image contains metadata (standard OpenWrt)
	if get_image "$1" | tar -Oxf - sysupgrade-board 2>/dev/null | grep -q .; then
		echo "Standard OpenWrt sysupgrade image detected"
		return 0
	fi

	echo "Image check passed"
	return 0
}

platform_do_upgrade() {
	local board=$(board_name)

	echo "platform_do_upgrade start"
	echo "board: $board"
	echo "image: $1"

	# Standard emmc upgrade
	sync
	echo 3 > /proc/sys/vm/drop_caches

	# Try to find the root partition
	local root_part=$(cat /proc/cmdline | sed 's/.*root=\([^ ]*\).*/\1/')
	echo "root partition: $root_part"

	if [ -b "$root_part" ]; then
		# Determine if we need to write to the other partition (A/B)
		local root_dev="${root_part%p*}"
		local part_num="${root_part##*p}"

		echo "root device: $root_dev"
		echo "partition number: $part_num"

		case "$part_num" in
			1|2)
				# A/B partition scheme
				local target_part=$((3 - part_num))  # 1->2, 2->1
				local target_dev="${root_dev}p${target_part}"
				echo "Writing to alternate partition: $target_dev"
				get_image "$1" | dd of="$target_dev" bs=1M status=progress
				;;
			*)
				# Single partition, use dd
				echo "Writing directly to root partition"
				get_image "$1" | dd of="$root_part" bs=1M status=progress
				;;
		esac
	else
		# Fallback to standard mtd write
		echo "Using standard upgrade method"
		default_do_upgrade "$1"
	fi

	echo "platform_do_upgrade end"
}

platform_copy_config() {
	local board=$(board_name)

	echo "platform_copy_config"

	# Copy config to boot partition or etc
	if [ -d /boot ]; then
		cp -a "$UPGRADE_BACKUP" /boot/
	fi
}