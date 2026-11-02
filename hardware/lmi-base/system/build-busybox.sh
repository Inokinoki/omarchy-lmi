#!/bin/bash
# Build a static aarch64 busybox from pinned source, for the boot initramfs.
#   BUSYBOX_VER    upstream version to fetch (e.g. 1.37.0)
#   BUSYBOX_SHA512 the tarball sha512; empty refuses to build (pin discipline
#                  as in build-kernel.sh: record it after the first verified
#                  download, never build from unpinned input)
#   BUSYBOX_BUILD  build scratch directory (default $PWD/build/busybox)
#   CROSS_COMPILE  cross prefix (default aarch64-linux-gnu-)
set -euo pipefail
VER=${BUSYBOX_VER:?Set BUSYBOX_VER}
EXPECTED=${BUSYBOX_SHA512:-}
BUILD=${BUSYBOX_BUILD:-$PWD/build/busybox}
CROSS=${CROSS_COMPILE:-aarch64-linux-gnu-}
mkdir -p "$BUILD/downloads"
cd "$BUILD/downloads"
ARCHIVE="busybox-$VER.tar.bz2"
if [ ! -s "$ARCHIVE" ]; then
    curl --fail --location --retry 3 --output "$ARCHIVE" \
        "https://busybox.net/downloads/$ARCHIVE"
fi
if [ -z "$EXPECTED" ]; then
    echo "Refusing to build: pin BUSYBOX_SHA512 to the sha512 of $ARCHIVE after verifying its provenance." >&2
    sha512sum "$ARCHIVE" >&2 || true
    exit 1
fi
printf '%s  %s\n' "$EXPECTED" "$ARCHIVE" | sha512sum -c -
if [ ! -d "$BUILD/busybox-$VER" ]; then
    tar -xjf "$ARCHIVE" -C "$BUILD"
fi
cd "$BUILD/busybox-$VER"
make defconfig >/dev/null
# The initramfs shell must run without a libc on the target.
sed -i 's/^# CONFIG_STATIC is not set$/CONFIG_STATIC=y/' .config
# busybox 1.37.x: networking/tc uses struct tc_cbq_wrropt, removed from
# modern kernel headers (upstream fix landed after 1.37). The boot initramfs
# never does traffic control; disable the applet.
sed -i 's/^CONFIG_TC=y$/# CONFIG_TC is not set/' .config
make -j"$(nproc)" CROSS_COMPILE="$CROSS" > "$BUILD/busybox-build.log" 2>&1
file busybox | grep -q 'statically linked' || {
    echo "busybox did not build static; inspect $BUILD/busybox-build.log" >&2
    exit 1
}
echo "BUSYBOX BUILD COMPLETE: $BUILD/busybox-$VER/busybox"
