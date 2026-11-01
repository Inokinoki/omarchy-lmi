#!/bin/bash
# Assemble the lmi boot initramfs: a gzipped newc cpio holding the static
# busybox, the verify-and-switch-root init, the reboot helper and the slot
# identity. The init (platform/omarchy-lmi-init) refuses to boot unless the
# baked-in checksum matches the base SquashFS, so the assembly always pairs
# an initramfs with one concrete base image.
#
#   --repo PATH            this repository checkout (for the init script and
#                          the reboot helper source)
#   --slot NAME            image slot name; validated exactly like the init
#   --base-squashfs PATH   the rootfs SquashFS to checksum and pair with
#   --busybox PATH         static aarch64 busybox (see build-busybox.sh)
#   --host-cc CC           aarch64 compiler for the reboot helper
#                          (default aarch64-linux-gnu-gcc)
#   --output PATH          initramfs to write
set -euo pipefail
repo='' slot='' base='' busybox='' host_cc=aarch64-linux-gnu-gcc output=''
while [ $# -gt 0 ]; do
    case "$1" in
        --repo) repo=$2; shift 2 ;;
        --slot) slot=$2; shift 2 ;;
        --base-squashfs) base=$2; shift 2 ;;
        --busybox) busybox=$2; shift 2 ;;
        --host-cc) host_cc=$2; shift 2 ;;
        --output) output=$2; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
: "${repo:?--repo required}" "${slot:?--slot required}" \
  "${base:?--base-squashfs required}" "${busybox:?--busybox required}" \
  "${output:?--output required}"
[ "$(basename "$busybox")" = busybox ] || { echo "--busybox must be the busybox binary" >&2; exit 2; }
file "$busybox" | grep -q 'statically linked' || { echo "busybox is not static" >&2; exit 2; }
# Same validation the init performs on the baked slot name.
case "$slot" in ''|*[!a-z0-9-]*) echo 'invalid image slot' >&2; exit 2;; esac
[ "${#slot}" -le 64 ] || { echo 'invalid image slot length' >&2; exit 2; }
[ -f "$base" ] || { echo "base squashfs missing: $base" >&2; exit 2; }
init="$repo/platform/omarchy-lmi-init"
[ -f "$init" ] || { echo "init script missing: $init" >&2; exit 2; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work"/{bin,sbin,etc,proc,sys,dev/pts,run,tmp,newroot,usr}
install -m755 "$busybox" "$work/bin/busybox"
ln -s busybox "$work/bin/sh"
# Deterministic applet links for everything the init calls; busybox resolves
# the rest of its applets through PATH itself.
for applet in mkdir mount grep cat seq sleep basename dirname sha256sum \
              chmod touch sync switch_root; do
    ln -s busybox "$work/bin/$applet"
done
"$host_cc" -static -Os -o "$work/sbin/reboot-bootloader" \
    "$repo/hardware/lmi-base/system/reboot-bootloader.c"
install -m755 "$init" "$work/init"
printf '%s\n' "$slot" > "$work/etc/omarchy-lmi-slot"
sha256sum -- "$base" | cut -d ' ' -f1 > "$work/etc/omarchy-lmi.sha256"
[ "$(wc -c < "$work/etc/omarchy-lmi.sha256")" -eq 65 ] || {
    echo 'unexpected checksum width' >&2; exit 2;
}
( cd "$work" && find . -print0 | cpio --null -o -H newc -R 0:0 2>/dev/null | gzip -9 ) > "$output"
echo "INITRAMFS COMPLETE: $output (slot $slot, base sha256 $(cat "$work/etc/omarchy-lmi.sha256"))"
