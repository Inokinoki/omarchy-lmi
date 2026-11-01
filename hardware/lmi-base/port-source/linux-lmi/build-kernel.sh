#!/bin/bash
# Build the lmi kernel: yuweiyuan8's close-to-mainline tree carrying the
# POCO F2 Pro device tree, Samsung AMS667UU01 panel driver and FocalTech FTS
# touch driver. Produces an Android-boot-image payload (Image.gz + DTB) plus
# stripped modules, mirroring the apollo build shape.
#
# Inputs (see docs/build.md):
#   LMI_BUILD      build scratch directory (default $PWD/build)
#   LMI_REPO       path to this repository checkout
set -euo pipefail
BUILD=${LMI_BUILD:-$PWD/build}
HOST=${LMI_REPO:?Set LMI_REPO to the checkout path}
# Pinned head of the v6.19 branch (resolved 2026-11-01; merge of
# sm7150-mainline v6.19 into yuweiyuan8's fork). The lmi DTS, panel and
# touch drivers are verified present at this commit.
COMMIT=999ef8bfd90ca4c214f18ac5d0138bf380386c38
# The tarball sha512 must be pinned after the first verified download and
# never left empty for production builds. An empty pin is an explicit
# pending marker: refuse to build rather than building from unpinned input.
EXPECTED=${LMI_TARBALL_SHA512:-}
mkdir -p "$BUILD/downloads" "$BUILD/kernel-out" "$BUILD/artifacts"
cd "$BUILD/downloads"
ARCHIVE="linux-$COMMIT.tar.gz"
if [ ! -s "$ARCHIVE" ]; then
    curl --fail --location --retry 3 --output "$ARCHIVE" \
        "https://github.com/yuweiyuan8/linux/archive/$COMMIT.tar.gz"
fi
if [ -z "$EXPECTED" ]; then
    echo "Refusing to build: pin LMI_TARBALL_SHA512 to the sha512 of $ARCHIVE after verifying its provenance." >&2
    sha512sum "$ARCHIVE" >&2 || true
    exit 1
fi
printf '%s  %s\n' "$EXPECTED" "$ARCHIVE" | sha512sum -c -
if [ ! -d "$BUILD/linux-$COMMIT" ]; then
    tar -xzf "$ARCHIVE" -C "$BUILD"
fi
cd "$BUILD/linux-$COMMIT"
# Patch framework: no patches are carried initially. The v6.19 tree already
# contains the lmi board support. If a SoC-level patch from the apollo port
# turns out to be needed (venus/iris IOVA, CCI, APR, clk), add it here with
# an idempotent guard, matching the apollo build-kernel.sh pattern:
#   if ! grep -q '<marker>' <file>; then
#     patch -Np1 --fuzz=0 < "$HOST/port-source/linux-lmi/000X-name.patch"
#   fi

# Kernel configuration. Base defconfig plus the platform and device options
# the phone image needs. The apollo .config (kept as ./config-apollo-reference here) is a
# reference for SM8250 platform choices, not a direct input: this tree is a
# different kernel version with different board drivers.
ARCH=arm64 LLVM=1 make O="$BUILD/kernel-out" defconfig
scripts/config --file "$BUILD/kernel-out/.config" \
    --enable SQUASHFS_ZSTD --enable ZRAM_BACKEND_ZSTD --enable SECURITY_LANDLOCK \
    --enable BT_LE --module BT_RFCOMM --enable BT_RFCOMM_TTY \
    --module BT_BNEP --enable BT_BNEP_MC_FILTER --enable BT_BNEP_PROTO_FILTER \
    --enable WATCHDOG_SYSFS --enable U_SERIAL_CONSOLE --enable DEVFREQ_THERMAL \
    --module SM_CAMCC_8250 --module I2C_QCOM_CCI \
    --module MHI_BUS_PCI_GENERIC \
    --enable QCOM_QSEECOM --module TEE_QSEECOM \
    --module DRM_PANEL_SAMSUNG_AMS667UU01 \
    --module TOUCHSCREEN_FOCALTECH_FTS \
    --disable RTC_HCTOSYS --disable RTC_SYSTOHC \
    --disable DEBUG_INFO_BTF
ARCH=arm64 LLVM=1 make O="$BUILD/kernel-out" olddefconfig
# Fail loudly if the fork renamed either board driver symbol: that is an
# upstream movement to review, not something to paper over.
for symbol in DRM_PANEL_SAMSUNG_AMS667UU01 TOUCHSCREEN_FOCALTECH_FTS; do
    grep -q "CONFIG_${symbol}=[ym]" "$BUILD/kernel-out/.config" || {
        echo "CONFIG_$symbol is not enabled; review the fork's Kconfig at commit $COMMIT" >&2
        exit 1
    }
done
# BTF is disabled above on purpose: it is not consumed on the phone and its
# vmlinux encoding exhausts the memory of CI-class runners.
JOBS=${LMI_JOBS:-$(nproc)}
make O="$BUILD/kernel-out" ARCH=arm64 LLVM=1 -j"$JOBS" Image.gz qcom/sm8250-xiaomi-lmi.dtb modules > "$BUILD/kernel-build.log" 2>&1
make O="$BUILD/kernel-out" ARCH=arm64 LLVM=1 INSTALL_MOD_PATH="$BUILD/artifacts" INSTALL_MOD_STRIP=1 modules_install >> "$BUILD/kernel-build.log" 2>&1
cp "$BUILD/kernel-out/arch/arm64/boot/Image.gz" "$BUILD/artifacts/"
cp "$BUILD/kernel-out/arch/arm64/boot/dts/qcom/sm8250-xiaomi-lmi.dtb" "$BUILD/artifacts/"
cp "$BUILD/kernel-out/include/config/kernel.release" "$BUILD/artifacts/"
echo "KERNEL BUILD COMPLETE"
cat "$BUILD/artifacts/kernel.release"
