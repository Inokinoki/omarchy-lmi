#!/bin/bash
# Build a static aarch64 busybox from pinned source, for the boot initramfs.
#   BUSYBOX_VER    upstream version to fetch (e.g. 1.37.0)
#   BUSYBOX_SHA512 the tarball sha512; empty refuses to build (pin discipline
#                  as in build-kernel.sh: record it after the first verified
#                  download, never build from unpinned input)
#   BUSYBOX_BUILD  build scratch directory (default $PWD/build/busybox)
#   CROSS_COMPILE  cross prefix; default aarch64-linux-gnu-, pass an empty
#                  string to build natively (e.g. inside an aarch64 container)
set -euo pipefail
VER=${BUSYBOX_VER:?Set BUSYBOX_VER}
EXPECTED=${BUSYBOX_SHA512:-ad8fd06f082699774f990a53d7a73b189ed404fe0a2166aff13eae4d9d8ee5c9239493befe949c98801fe7897520dbff3ed0224faa7205854ce4fa975e18467e}
BUILD=${BUSYBOX_BUILD:-$PWD/build/busybox}
CROSS=${CROSS_COMPILE-aarch64-linux-gnu-}
if [ -n "$CROSS" ] && ! command -v "${CROSS}ar" >/dev/null; then
    echo "cross toolchain incomplete: ${CROSS}ar not found; set CROSS_COMPILE= for a native aarch64 build" >&2
    exit 1
fi
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
# busybox 1.37.x: the SHA hardware-acceleration code references
# sha1_process_block64_shaNI unconditionally in a translation unit that does
# not declare it on some arch/gcc combinations (reproduced on aarch64 gcc),
# breaking the build. The initramfs sha256sum usage is light; use the plain
# C implementation.
sed -i 's/^CONFIG_SHA1_HWACCEL=y$/# CONFIG_SHA1_HWACCEL is not set/; s/^CONFIG_SHA256_HWACCEL=y$/# CONFIG_SHA256_HWACCEL is not set/' .config
make -j"$(nproc)" CROSS_COMPILE="$CROSS" 2>&1 | tee "$BUILD/busybox-build.log" | grep --line-buffered -E "(error|Error|LINK)" || {
    echo "busybox build failed; see $BUILD/busybox-build.log" >&2
    tail -20 "$BUILD/busybox-build.log" >&2
    exit 1
}
file busybox | grep -q 'statically linked' || {
    echo "busybox did not build static; inspect $BUILD/busybox-build.log" >&2
    exit 1
}
echo "BUSYBOX BUILD COMPLETE: $BUILD/busybox-$VER/busybox"
