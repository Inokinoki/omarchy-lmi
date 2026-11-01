#!/bin/bash
# Assemble the Android boot image for the lmi boot partition: Android boot
# header v2, page size 4096, base 0x00000000, Image.gz kernel, device-tree
# blob and the boot initramfs. The header parameters and the default kernel
# command line come from the LineageOS device tree for this device
# (android_device_xiaomi_sm8250-common BoardConfigCommon, lineage-23.2:
# BOARD_BOOT_HEADER_VERSION 2, BOARD_KERNEL_BASE 0x00000000,
# BOARD_KERNEL_PAGESIZE 4096, no separate offset overrides, and the stock
# BOARD_KERNEL_CMDLINE verbatim). The mainline kernel ignores the
# downstream-only arguments; carrying them keeps the boot environment close
# to what ABL and the device normally see. `console=` is prepended so the
# initramfs fatal path is visible on the serial console.
# Flashing an empty DTBO alongside it is part of installation (see
# docs/status.md); this script never writes a device partition.
#
#   --kernel PATH      Image.gz from build-kernel.sh
#   --dtb PATH         sm8250-xiaomi-lmi.dtb
#   --ramdisk PATH     initramfs from build-initramfs.sh
#   --mkbootimg PATH   mkbootimg.py from the pinned AOSP mkbootimg commit
#                      (d2bb0af5ba6d3198a3e99529c97eda1be0b5a093)
#   --output PATH      boot image to write
#   --cmdline STR      kernel command line (default below)
#
# TODO(M1): compare this header against the stock lmi boot.img
# (unpack_bootimg.py --boot_img stock.img) at first bring-up; adjust --base
# or offsets here if the device refuses the image.
set -euo pipefail
kernel='' dtb='' ramdisk='' mkbootimg='' output=''
cmdline='console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket reboot=panic_warm androidboot.fstab_suffix=qcom androidboot.init_fatal_reboot_target=recovery'
while [ $# -gt 0 ]; do
    case "$1" in
        --kernel) kernel=$2; shift 2 ;;
        --dtb) dtb=$2; shift 2 ;;
        --ramdisk) ramdisk=$2; shift 2 ;;
        --mkbootimg) mkbootimg=$2; shift 2 ;;
        --output) output=$2; shift 2 ;;
        --cmdline) cmdline=$2; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
: "${kernel:?--kernel required}" "${dtb:?--dtb required}" \
  "${ramdisk:?--ramdisk required}" "${mkbootimg:?--mkbootimg required}" \
  "${output:?--output required}"
for f in "$kernel" "$dtb" "$ramdisk" "$mkbootimg"; do
    [ -f "$f" ] || { echo "missing input: $f" >&2; exit 2; }
done
python3 "$mkbootimg" \
    --kernel "$kernel" \
    --ramdisk "$ramdisk" \
    --dtb "$dtb" \
    --header_version 2 \
    --pagesize 4096 \
    --base 0x00000000 \
    --cmdline "$cmdline" \
    --output "$output"
echo "BOOT IMAGE COMPLETE: $output (header v2, page 4096, base 0x0, cmdline: $cmdline)"
