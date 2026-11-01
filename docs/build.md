# Build status and recipes

These are integration packages for an already provisioned LMI Linux base. This repository does not yet provide a validated installer from stock Android. Do not use a generic Omarchy ISO or format phone partitions with PC installation instructions.

Build as an ordinary user in a clean checkout on aarch64 with the matching, signature-verified Omarchy ARM edge and Arch Linux ARM repositories. The runtime recipe is the root `PKGBUILD`. It fetches a pinned upstream git commit and applies `patches/`. The LMI kernel, camera and firmware packages remain separate components of the reviewed device stack.

The recipes in `packaging/` build additional components. Put each recipe at the root of a separate clean staging copy of this repository as `PKGBUILD`, then use `makepkg` there. The keyboard recipe pins upstream wvkbd v0.20 plus a checksum-verified Hyprland lock-notify protocol and the native input/lifecycle patch; it links to libsystemd for service readiness. The mobile recipe installs interface templates, the guarded keyboard launcher, its notify service and the PIN-enrollment success hook; the Android recipe installs the ext4 bind-mount dependency, on-demand launcher, confirmed APK installer, D-Bus policy and APK file handler. The Android recipe explicitly depends on `xdg-utils` for selecting that handler.

Cameras are not packaged yet: there is no `libcamera-lmi` recipe because the lmi sensor set is unproven. The wireplumber naming configuration and `tests/check_camera_streams.py` are explicit pending stubs; fill them during the M3 camera work in [hardware status](../hardware/lmi-base/docs/status.md).

The firmware recipe (`packaging/firmware.PKGBUILD`) consumes a device-extracted private tarball whose sha512 is a `SKIP` pending marker until the owner performs the extraction; see the M1 checklist in that status page. The kernel is built with `hardware/lmi-base/port-source/linux-lmi/build-kernel.sh` from the pinned yuweiyuan8 v6.19 commit.

The lock recipe builds the local enrollment application and the narrowly scoped setuid verifier. Installing its package does not enroll an owner PIN or turn on automatic locking. PIN entry and confirmation happen on the device. Keep the Unix administration password separate.

Authentication checks can be run on the test device with `sudo python tests/check_pin_auth.py`. They require the compiler and PAM/libxcrypt development headers, create a temporary non-login account and an isolated verifier directory, then remove them. They do not enroll or use the owner's PIN. The source checks live at `tools/check_sources.py` and establish source integrity and syntax, not hardware functionality.

The Android integration checks use `sudo python -I tests/check_android_lifecycle.py --apk /path/to/verified/F-Droid-2.0.2.apk` on a provisioned development device with Android stopped and the optional Weston test tool installed. They install a known fixture into the existing Android environment and create a separate headless display. Follow the signature and fixture requirements in [Android usage and tests](android.md). On the apollo device this suite recorded 31 successful checks; on lmi it has not been run yet.

Native camera checks are not runnable: `tests/check_camera_streams.py` is a pending stub that refuses to run until the M3 camera bring-up provides real sensor nodes.

The update boundary can be checked with `sudo python tests/check_update_guard.py`. It uses real pacman transactions against generated local packages in disposable roots, with no network access and no changes to the live package database. Read the [development update policy](updates.md) before changing any boot, kernel, firmware or camera package. The current generic PC full-system updater is deliberately stopped; an LMI upgrade and rollback workflow still needs implementation and device validation.

Building a package does not install it, initialize Android, migrate existing Android data, seed a user's desktop or select a display-manager session. Those migration steps are being validated on the test device before becoming a public installer. The current development workflow retains the previous desktop configuration, original Android data directory and boot/recovery backups privately.

CI runs two always-on jobs on every push: the source checks (`tools/check_sources.py`) and a sequential `--fuzz=0` dry-run of the patch series against the pinned upstream Omarchy commit. A manual `workflow_dispatch` job cross-builds the aarch64 kernel payload on a GitHub runner and uploads `Image.gz`, the DTB, `kernel.release` and the recorded tarball sha512; that hash is what the pin in `build-kernel.sh` expects.

Record the upstream commit, resulting package checksums, dependencies changed and actual device tests for every release. Local integration builds and official signed repository packages must remain distinguishable. Do not disable signature verification to make a remote package install.
