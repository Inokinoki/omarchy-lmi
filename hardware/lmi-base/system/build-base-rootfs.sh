#!/bin/bash
# Build the base SquashFS root for the POCO F2 Pro slot image.
#
# Prerequisites: run as root on an aarch64-capable Linux host — native, a
# container, or x86_64 with qemu-user binfmt registered for aarch64 (pacman
# itself must run aarch64 binaries). Requires arch-install-scripts (pacstrap,
# arch-chroot), squashfs-tools (mksquashfs) and a pacman configured with the
# signature-verified Arch Linux ARM repositories.
#
#   --repo PATH        this checkout (package list, upstream commit)
#                      default: the script's checkout
#   --pkgs DIR         directory of locally built *.pkg.tar.* packages from
#                      this repository. Must include omarchy-keyring (from
#                      the Omarchy ARM repository or omarchy-pkgs) and the
#                      built set: linux-lmi, omarchy-lmi, omarchy-lmi-mobile,
#                      omarchy-lmi-lock, omarchy-lmi-android,
#                      omarchy-lmi-device, lmi-device-firmware,
#                      wvkbd-mobintl-lmi, quickshell, hyprgraphics.
#   --output-dir DIR   default $PWD/build/image; writes omarchy-lmi.sqfs
#   --scratch DIR      default $PWD/build/rootfs; the rootfs staging tree
#
# After building, generate the install manifest with make-install-manifest.py
# (userdata_size comes from install-persistent's read-only preflight output).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
pkgs='' output_dir="$PWD/build/image" scratch="$PWD/build/rootfs"
while [ $# -gt 0 ]; do
    case "$1" in
        --repo) repo=$2; shift 2 ;;
        --pkgs) pkgs=$2; shift 2 ;;
        --output-dir) output_dir=$2; shift 2 ;;
        --scratch) scratch=$2; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[ "$(id -u)" -eq 0 ] || { echo 'root required (pacstrap mounts and chroots)' >&2; exit 2; }
[ "$(uname -m)" = aarch64 ] || echo "warning: $(uname -m) host; pacman must still run aarch64 binaries (binfmt) or this fails at pacstrap" >&2
for tool in pacstrap arch-chroot mksquashfs pacman systemd-machine-id-setup; do
    command -v "$tool" >/dev/null || { echo "missing tool: $tool" >&2; exit 2; }
done
[ -n "$pkgs" ] || { echo "--pkgs required" >&2; exit 2; }
[ -d "$pkgs" ] || { echo "package directory missing: $pkgs" >&2; exit 2; }
shopt -s nullglob
pkgs_files=("$pkgs"/*.pkg.tar.*)
shopt -u nullglob
[ "${#pkgs_files[@]}" -gt 0 ] || { echo "no *.pkg.tar.* packages in $pkgs" >&2; exit 2; }
for want in omarchy-keyring omarchy-lmi- linux-lmi lmi-device-firmware; do
    ls "$pkgs"/${want}*.pkg.tar.* >/dev/null 2>&1 || {
        echo "package directory lacks ${want}*" >&2; exit 2;
    }
done
pkglist="$repo/config/install/clean-packages.txt"
[ -f "$pkglist" ] || { echo "package list missing: $pkglist" >&2; exit 2; }
upstream_commit=$(grep -oP '(?<=^_commit=)[0-9a-f]{40}' "$repo/PKGBUILD")

rm -rf "$scratch"
mkdir -p "$scratch" "$output_dir"
# Repository packages from the clean list; comments and blanks skipped.
mapfile -t repo_pkgs < <(grep -vE '^\s*(#|$)' "$pkglist")
echo "pacstrap: ${#repo_pkgs[@]} repository packages"
pacstrap -c -G -M "$scratch" "${repo_pkgs[@]}"

echo "installing ${#pkgs_files[@]} local packages"
pacman --sysroot "$scratch" -U --noconfirm "${pkgs_files[@]}"

# Identity and account baseline. The Unix account stays password-locked;
# authentication is the numeric PIN verifier (docs/architecture.md).
systemd-machine-id-setup --root="$scratch"
echo lmi > "$scratch/etc/hostname"
chroot "$scratch" useradd -m -u 1001 -G wheel -s /bin/bash lmi
chroot "$scratch" passwd -l lmi
install -dm755 "$scratch/etc/sudoers.d"
printf '%%wheel ALL=(ALL:ALL) ALL\n' > "$scratch/etc/sudoers.d/00-lmi-wheel"
chmod 440 "$scratch/etc/sudoers.d/00-lmi-wheel"

# The marker the boot init requires on the merged root.
install -dm755 "$scratch/etc/omarchy-lmi"
printf '{\n  "upstream_commit": "%s",\n  "generated_at": "%s"\n}\n' \
    "$upstream_commit" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    > "$scratch/etc/omarchy-lmi/clean-image.json"

# System services for the phone baseline; user services are enabled globally
# so the desktop account picks them up at first login.
for unit in lmi-usb-gadget.service omarchy-lmi-clock-restore.service \
            omarchy-lmi-clock-save.timer omarchy-lmi-pin-ready-lock.service \
            omarchy-lmi-pin-ready-keyboard.service omarchy-lmi-apk.service \
            var-lib-waydroid.mount NetworkManager.service sshd.service; do
    systemctl --root="$scratch" enable "$unit" 2>/dev/null \
        || echo "warning: unit not present, review before flashing: $unit" >&2
done
for unit in omarchy-lmi-keyboard.service omarchy-lmi-display.service \
            omarchy-lmi-startup-lock.service; do
    systemctl --root="$scratch" --global enable "$unit" 2>/dev/null \
        || echo "warning: user unit not present, review before flashing: $unit" >&2
done

echo "packing squashfs"
mksquashfs "$scratch" "$output_dir/omarchy-lmi.sqfs" -comp zstd -Xcompression-level 19 -noappend
sha256sum "$output_dir/omarchy-lmi.sqfs"
echo "BASE ROOTFS COMPLETE: $output_dir/omarchy-lmi.sqfs"
echo "Next: hardware/lmi-base/system/make-install-manifest.py for the install manifest."
