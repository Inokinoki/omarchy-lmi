# Build status and recipes

These are integration packages for an already provisioned LMI Linux base. This repository does not yet provide a validated installer from stock Android. Do not use a generic Omarchy ISO or format phone partitions with PC installation instructions.

Build as an ordinary user in a clean checkout on aarch64 with the matching, signature-verified Omarchy ARM edge and Arch Linux ARM repositories. The runtime recipe is the root `PKGBUILD`. It fetches a pinned upstream git commit and applies `patches/`. The LMI kernel, camera and firmware packages remain separate components of the reviewed device stack.

The recipes in `packaging/` build additional components. Put each recipe at the root of a separate clean staging copy of this repository as `PKGBUILD`, then use `makepkg` there. The keyboard recipe pins upstream wvkbd v0.20 plus a checksum-verified Hyprland lock-notify protocol and the native input/lifecycle patch; it links to libsystemd for service readiness. The mobile recipe installs interface templates, the guarded keyboard launcher, its notify service and the PIN-enrollment success hook; the Android recipe installs the ext4 bind-mount dependency, on-demand launcher, confirmed APK installer, D-Bus policy and APK file handler. The Android recipe explicitly depends on `xdg-utils` for selecting that handler.

Cameras are not packaged yet: there is no `libcamera-lmi` recipe because the lmi sensor set is unproven. The wireplumber naming configuration and `tests/check_camera_streams.py` are explicit pending stubs; fill them during the M3 camera work in [hardware status](../hardware/lmi-base/docs/status.md).

The firmware recipe (`packaging/firmware.PKGBUILD`) consumes a device-extracted private tarball whose sha512 is a `SKIP` pending marker until the owner performs the extraction; see the M1 checklist in that status page. The kernel is built with `hardware/lmi-base/port-source/linux-lmi/build-kernel.sh` from the pinned yuweiyuan8 v6.19 commit.

The boot chain has three assembly steps under `hardware/lmi-base/system/`, all runnable on a Linux host and exercised end-to-end in the manual `bootimage` CI job:

1. `build-busybox.sh` builds a static aarch64 busybox from pinned busybox source (same record-first-run-hash discipline as the kernel).
2. `build-initramfs.sh` assembles the boot initramfs: static busybox, the verify-and-switch-root init, the `reboot-bootloader` helper and the slot identity. It bakes the sha256 of one concrete base SquashFS into `/etc/omarchy-lmi.sha256`; the init refuses to boot that initramfs against any other base.
3. `build-bootimg.sh` packs Image.gz, the DTB and the initramfs into an Android boot header v2 image with page size 4096 — the shape the apollo port booted on the same kona ABL. Before the first flash, compare the header against the stock lmi boot.img with the pinned tool's `unpack_bootimg.py`; the default kernel command line is the stock LineageOS one (with `console=` prepended); verify the header against the device's stock boot.img at first bring-up.

The CI `bootimage` job runs all three against a **fixture** base (a SquashFS holding only the slot marker). The fixture boot image boots, fails the init's own `systemd missing` check and reboots to the bootloader by design; it validates the assembly pipeline and the image structure and must never be used for installation. The real image build is the local, owner-run sequence below.

## Local image build (M1, on an aarch64-capable Linux host)

1. **Firmware input.** `packaging/firmware-model/assemble-firmware.sh --output private-inputs/firmware-xiaomi-lmi-0.1.tar.gz` assembles the private tarball from the pinned community device-extracted commit (or `--source device --device-dir ...` from the owner's own extraction), verifies the file list one-for-one and prints the sha512 to pin into `packaging/firmware.PKGBUILD`.
2. **Kernel package.** Build `hardware/lmi-base/port-source/linux-lmi/PKGBUILD` with the `lmi-kernel-assets` tar.xz from the CI `kernel` job (or a local `build-kernel.sh` run), then pin the tar.xz sha512 into that PKGBUILD.
3. **Component packages.** For each recipe in `packaging/` (wvkbd, lock, mobile, android, device, firmware) plus the root `PKGBUILD`, stage a clean copy of this checkout, place the recipe at its root as `PKGBUILD`, and run `makepkg`. Collect every `*.pkg.tar.*` into one directory together with `omarchy-keyring` from the Omarchy ARM repository.
4. **Base rootfs.** As root on an aarch64-capable host: `hardware/lmi-base/system/build-base-rootfs.sh --pkgs <package-dir>` pacstraps the `config/install/clean-packages.txt` set, installs the local packages, creates the password-locked `lmi` account (UID 1001, wheel), writes the `/etc/omarchy-lmi/clean-image.json` marker the boot init requires, enables the phone service baseline and packs `omarchy-lmi.sqfs`. The installer and the init share one exact filename (`base/omarchy-lmi.sqfs`).
5. **Real initramfs and boot image.** Re-run `build-initramfs.sh` against the real `omarchy-lmi.sqfs` (it bakes that image's sha256), then `build-bootimg.sh` as usual.
6. **Install manifest.** `hardware/lmi-base/system/make-install-manifest.py --base omarchy-lmi.sqfs --boot boot.img --output manifest.json --userdata-size N`, where N is the `userdata_bytes` reported by install-persistent's read-only preflight on the device.
7. **Install.** From the tested RAM system on the phone: `install-persistent --manifest manifest.json --base omarchy-lmi.sqfs --boot boot.img` (read-only preflight first; the erase path needs the explicit data-loss token and the local authorization marker).

The lock recipe builds the local enrollment application and the narrowly scoped setuid verifier. Installing its package does not enroll an owner PIN or turn on automatic locking. PIN entry and confirmation happen on the device. Keep the Unix administration password separate.

Authentication checks can be run on the test device with `sudo python tests/check_pin_auth.py`. They require the compiler and PAM/libxcrypt development headers, create a temporary non-login account and an isolated verifier directory, then remove them. They do not enroll or use the owner's PIN. The source checks live at `tools/check_sources.py` and establish source integrity and syntax, not hardware functionality.

The Android integration checks use `sudo python -I tests/check_android_lifecycle.py --apk /path/to/verified/F-Droid-2.0.2.apk` on a provisioned development device with Android stopped and the optional Weston test tool installed. They install a known fixture into the existing Android environment and create a separate headless display. Follow the signature and fixture requirements in [Android usage and tests](android.md). On the apollo device this suite recorded 31 successful checks; on lmi it has not been run yet.

Native camera checks are not runnable: `tests/check_camera_streams.py` is a pending stub that refuses to run until the M3 camera bring-up provides real sensor nodes.

The update boundary can be checked with `sudo python tests/check_update_guard.py`. It uses real pacman transactions against generated local packages in disposable roots, with no network access and no changes to the live package database. Read the [development update policy](updates.md) before changing any boot, kernel, firmware or camera package. The current generic PC full-system updater is deliberately stopped; an LMI upgrade and rollback workflow still needs implementation and device validation.

Building a package does not install it, initialize Android, migrate existing Android data, seed a user's desktop or select a display-manager session. Those migration steps are being validated on the test device before becoming a public installer. The current development workflow retains the previous desktop configuration, original Android data directory and boot/recovery backups privately.

CI runs two always-on jobs on every push: the source checks (`tools/check_sources.py`) and a sequential `--fuzz=0` dry-run of the patch series against the pinned upstream Omarchy commit. Manual `workflow_dispatch` jobs cross-build the aarch64 kernel payload and assemble the boot chain: the `kernel` job uploads Image.gz, the DTB, modules, kernel.release, the recorded source-tarball sha512 and a ready-to-consume lmi-kernel-assets tar.xz for the linux-lmi package; the `bootimage` job builds on it and uploads a fixture boot image and initramfs with a round-tripped header. The recorded hashes are what the pins in build-kernel.sh, the busybox recipe and that PKGBUILD expect.

Record the upstream commit, resulting package checksums, dependencies changed and actual device tests for every release. Local integration builds and official signed repository packages must remain distinguishable. Do not disable signature verification to make a remote package install.
