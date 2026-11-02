#!/bin/bash
# Build the public package set and the base rootfs inside the builder image.
# Runs as root with /work mounted: src/ (staged checkout with the kernel assets
# and firmware input in place), omarchy-pkgs/ (pinned keyring sources).
# Writes pkgs/ (the built packages) and out/omarchy-lmi.sqfs.
#
# The device-private recipes (lmi-dsp, lmi-modem) need inputs extracted from
# the owner's phone and are not built here; install them into the image locally.
set -euo pipefail
W=/work S=/work/src PK=/work/pkgs
mkdir -p "$PK" "$W/stage" "$W/out"
chown -R builder "$W/stage" "$PK" "$W/omarchy-pkgs"

# omarchy-keyring comes from sha512-pinned sources; it carries the key that
# signs the Omarchy ARM repository, so the repository is then used with
# signature checking left on.
runuser -u builder -- bash -c "cd $W/omarchy-pkgs/pkgbuilds/omarchy-keyring && PKGDEST=$PK makepkg -f --noconfirm"
pacman -U --noconfirm "$PK"/omarchy-keyring-*.pkg.tar.*
pacman-key --populate omarchy
# Local packages first so the pinned hyprgraphics and quickshell win over the
# moving repository versions.
sed -i 's|^\[core\]|[lmi-local]\nSigLevel = Optional TrustAll\nServer = file://'"$PK"'\n\n[omarchy]\nServer = https://pkgs.omarchy.org/edge/$arch\n\n[core]|' /etc/pacman.conf
repo-add -q "$PK/lmi-local.db.tar.gz" "$PK"/omarchy-keyring-*.pkg.tar.*

build() { # name dir [recipe path inside the checkout]
    local name=$1 dir=$2 recipe=${3:-} t=$W/stage/$1
    echo "::group::makepkg $name"
    rm -rf "$t"; cp -a "$dir" "$t"
    [ -z "$recipe" ] || cp "$S/$recipe" "$t/PKGBUILD"
    chown -R builder "$t"
    pacman -Sy --noconfirm >/dev/null
    runuser -u builder -- bash -c "cd $t && PKGDEST=$PK makepkg -sf --noconfirm"
    repo-add -q "$PK/lmi-local.db.tar.gz" "$PK/$name"-[0-9]*.pkg.tar.*
    echo "::endgroup::"
}

# hyprgraphics: reproduce the pinned upstream archive, as its README describes.
git init -q "$W/hyprgraphics-source"
git -C "$W/hyprgraphics-source" remote add origin https://github.com/hyprwm/hyprgraphics
git -C "$W/hyprgraphics-source" fetch -q --depth 1 origin 482d4b7ec36ffdaf3573086aa586b178fd5404be
git -c core.autocrlf=false -c core.eol=lf -C "$W/hyprgraphics-source" archive \
    --format=tar --prefix=hyprgraphics-0.5.1/ \
    --output="$S/packaging/hyprgraphics/hyprgraphics-0.5.1.tar" FETCH_HEAD

build hyprgraphics   "$S/packaging/hyprgraphics"
build quickshell     "$S/packaging/quickshell"
build wvkbd-mobintl-lmi "$S" packaging/wvkbd.PKGBUILD
build omarchy-lmi    "$S"
build omarchy-lmi-lock    "$S" packaging/lock.PKGBUILD
build omarchy-lmi-mobile  "$S" packaging/mobile.PKGBUILD
build omarchy-lmi-android "$S" packaging/android.PKGBUILD
build omarchy-lmi-device  "$S" packaging/device.PKGBUILD
build lmi-device-firmware "$S" packaging/firmware.PKGBUILD
build linux-lmi      "$S/hardware/lmi-base/port-source/linux-lmi"

ls -l "$PK"/*.pkg.tar.*
"$S/hardware/lmi-base/system/build-base-rootfs.sh" \
    --repo "$S" --pkgs "$PK" --output-dir "$W/out" --scratch "$W/rootfs"
