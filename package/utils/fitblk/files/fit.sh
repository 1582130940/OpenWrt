export_fitblk_bootdev() {
	[ -e /sys/firmware/devicetree/base/chosen/rootdisk ] || return

	local rootdisk="$(cat /sys/firmware/devicetree/base/chosen/rootdisk)"
	local handle bootdev

	for handle in /sys/class/mtd/mtd*/of_node/volumes/*/phandle; do
		[ ! -e "$handle" ] && continue
		if [ "$rootdisk" = "$(cat "$handle")" ]; then
			if [ -e "${handle%/phandle}/volname" ]; then
				export CI_KERNPART="$(cat "${handle%/phandle}/volname")"
			elif [ -e "${handle%/phandle}/volid" ]; then
				export CI_KERNVOLID="$(cat "${handle%/phandle}/volid")"
			else
				return
			fi
			export CI_UBIPART="$(cat "${handle%%/of_node*}/name")"
			export CI_METHOD="ubi"
			return
		fi
	done

	for handle in /sys/class/mtd/mtd*/of_node/phandle; do
		[ ! -e "$handle" ] && continue
		if [ "$rootdisk" = "$(cat $handle)" ]; then
			bootdev="${handle%/of_node/phandle}"
			bootdev="${bootdev#/sys/class/mtd/}"
			export PART_NAME="/dev/$bootdev"
			export CI_METHOD="default"
			return
		fi
	done

	for handle in /sys/class/block/*/of_node/phandle; do
		[ ! -e "$handle" ] && continue
		if [ "$rootdisk" = "$(cat $handle)" ]; then
			bootdev="${handle%/of_node/phandle}"
			bootdev="${bootdev#/sys/class/block/}"
			export EMMC_KERN_DEV="/dev/$bootdev"
			export CI_METHOD="emmc"
			return
		fi
	done
}

fitblk_release_dev() {
	local dev="${1##*/}"
	local i

	[ -e "/dev/$dev" ] || return 0

	fitblk "/dev/$dev" >/dev/null 2>&1 || return 1

	for i in 1 2 3 4 5 6 7 8 9 10; do
		[ ! -e "/sys/class/block/$dev" ] && return 0
		sleep 1
	done

	echo "fitblk: /dev/$dev did not disappear after release" >&2
	return 1
}

fit_do_upgrade() {
	export_fitblk_bootdev
	[ -n "$CI_METHOD" ] || return 1
	fitblk_release_dev /dev/fit0 || return 1
	fitblk_release_dev /dev/fitrw || return 1

	case "$CI_METHOD" in
	emmc)
		emmc_do_upgrade "$1"
		;;
	default)
		default_do_upgrade "$1"
		;;
	ubi)
		nand_do_upgrade "$1"
		;;
	esac
}

fit_check_image() {
	local magic="$(get_magic_long "$1")"
	[ "$magic" != "d00dfeed" ] && {
		echo "Invalid image type."
		return 74
	}

	fit_check_sign -f "$1" >/dev/null || return 74
}
