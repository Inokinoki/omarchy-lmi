# Provenance

What this repository is built from, and what status each source carries.

## Inherited: omarchy-apollo (desktop/mobile integration)

- Source: the omarchy-apollo repository at commit `14c1352` ("Fix automatic
  phone locking with verified idle notification lifetime").
- What was taken: `platform/`, `lock/`, `config/`, `tests/`, the root
  `PKGBUILD` and `packaging/` recipes (mobile, lock, android, wvkbd, device,
  quickshell, hyprgraphics, wvkbd patch), `CONTRIBUTING.md`, `SECURITY.md`,
  `LICENSE`, and the generic Qualcomm userspace recipes in
  `hardware/lmi-base/port-source/` (qcom-core, pd-mapper, libssc,
  iio-sensor-proxy, modemmanager, bluetooth-address, location, video, dsp,
  modem).
- What was changed: the device identity mapping (codename `apollo` → `lmi`,
  device-tree token `xiaomi,apollo` → `xiaomi,lmi`, platform
  `aarch64-apollo` → `aarch64-lmi`, D-Bus names, env vars, install paths,
  account name), the 60 Hz refresh whitelist, the camera configuration and
  stream check (now pending stubs), the firmware recipe (rewritten for the
  lmi firmware layout), and the model assert in
  `hardware/lmi-base/system/install-persistent`. Documentation was rewritten
  to state inherited validation instead of carrying apollo device-evidence
  claims.
- License: MIT, per the inherited `LICENSE`.

## New for this port

- `hardware/lmi-base/port-source/linux-lmi/build-kernel.sh` — build recipe
  for the kernel below.
- `packaging/firmware.PKGBUILD` + `packaging/firmware-model/files.txt` —
  lmi firmware layout (rewritten; no apollo firmware entries).
- `hardware/lmi-base/port-source/lmi-board-data/README.md` — audio status
  and starting quirks for the UCM work (no UCM files yet).
- `hardware/lmi-base/docs/status.md` — hardware matrix and M1/M2/M3
  checklists.
- `README.md`, `PROVENANCE.md`, `docs/architecture.md` (lmi sections),
  `docs/roadmap.md` (milestones).

## Kernel basis

- Source: [yuweiyuan8/linux](https://github.com/yuweiyuan8/linux), branch
  `v6.19`, pinned commit `999ef8bfd90ca4c214f18ac5d0138bf380386c38`
  (head resolved 2026-11-01; verified at that commit to contain
  `arch/arm64/boot/dts/qcom/sm8250-xiaomi-lmi.dts`,
  `drivers/gpu/drm/panel/panel-samsung-ams667uu01.c` with Kconfig symbol
  `DRM_PANEL_SAMSUNG_AMS667UU01`, and `drivers/input/touchscreen/focaltech_fts.c`
  with Kconfig symbol `TOUCHSCREEN_FOCALTECH_FTS`).
- Tarball sha512: pending first verified download; `build-kernel.sh` refuses
  to build until `LMI_TARBALL_SHA512` is pinned.
- License: GPL-2.0, per the kernel tree.
- Related bring-up references: the
  [ccc007ccc/linux-sm8250-xiaomi-lmi](https://github.com/ccc007ccc/linux-sm8250-xiaomi-lmi)
  adaptation notes, the
  [postmarketOS wiki page for xiaomi-lmi](https://wiki.nura.eco/wiki/Xiaomi_POCO_F2_Pro_/_Redmi_K30_Pro_(xiaomi-lmi)),
  and [yuweiyuan8/firmware-xiaomi-lmi](https://github.com/yuweiyuan8/firmware-xiaomi-lmi)
  as the firmware layout reference.

## LineageOS device tree values

Filled from the LineageOS trees for this device (lineage-23.2), verified
2026-11-01:

- Boot image parameters: `android_device_xiaomi_sm8250-common`
  `BoardConfigCommon.mk` — `BOARD_BOOT_HEADER_VERSION := 2`,
  `BOARD_KERNEL_BASE := 0x00000000`, `BOARD_KERNEL_PAGESIZE := 4096`, no
  separate offset overrides, and the stock `BOARD_KERNEL_CMDLINE`, carried
  verbatim (with `console=` prepended) into
  `hardware/lmi-base/system/build-bootimg.sh`. The mainline kernel ignores
  the downstream-only arguments.
- Firmware provenance: the device-extracted firmware set is
  [yuweiyuan8/firmware-xiaomi-lmi](https://github.com/yuweiyuan8/firmware-xiaomi-lmi)
  @ `dde156380b2ac372619ed332dbe60640b838b7fe` (main, resolved 2026-11-01),
  whose `lib/firmware/qcom/sm8250/xiaomi/lmi/` matches
  `packaging/firmware-model/files.txt` one for one. The LineageOS vendor
  blob repository ([TheMuppets/proprietary_vendor_xiaomi_lmi](https://github.com/TheMuppets/proprietary_vendor_xiaomi_lmi)
  @ `bfe578af3b2ddcec5428010c862bbcd49401ca21`, lineage-23.2) is the
  reference for userspace-adjacent firmware such as the TFA9874 speaker
  configuration (`vendor/firmware/tfa98xx.cnt`), noted in the M2 audio
  plan. Neither repository's binaries are stored here.
- Device-tree model string: `model = "Xiaomi POCO F2 Pro"` in the pinned
  mainline DTS; pre-filled into
  `hardware/lmi-base/system/install-persistent`.

## Hardware comparison reference

The LineageOS device trees for both devices —
[android_device_xiaomi_lmi](https://github.com/LineageOS/android_device_xiaomi_lmi),
[android_device_xiaomi_apollon](https://github.com/LineageOS/android_device_xiaomi_apollon),
the shared
[android_device_xiaomi_sm8250-common](https://github.com/LineageOS/android_device_xiaomi_sm8250-common)
and [android_kernel_xiaomi_sm8250](https://github.com/LineageOS/android_kernel_xiaomi_sm8250) —
were used to compare the two boards (panel, touch, amplifier, fingerprint,
sensors, camera set, charger, NFC). They are not sources for any code in
this repository.

## Upstream Omarchy

- Pinned commit `717175d4a8c5a12f6c0fff10dcc3c1c08ef3a0d1` of
  [omacom/omarchy](https://github.com/omacom/omarchy), adapted by the seven
  patches in `patches/`. Patch 0001 (platform lifecycle) is rewritten for
  the lmi identity; patches 0002–0007 are the apollo series with only
  naming-level changes.
