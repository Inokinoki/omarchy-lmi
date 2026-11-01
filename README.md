# Omarchy LMI

**Omarchy on a Snapdragon phone. Native Linux, touch-first controls, Android apps when you need them.**

Omarchy LMI brings the normal Omarchy workflow to the **POCO F2 Pro** (`lmi`, M2004J11G, also sold as Redmi K30 Pro). It is a sibling port of [omarchy-apollo](https://github.com/LucasLG92/omarchy-apollo) (Xiaomi Mi 10T Pro): the same SM8250 "kona" platform, the same pinned Omarchy desktop, and the same touch-first mobile integration — a reachable app launcher, touch keyboard, screen controls, numeric authentication and phone-style power-button behavior — on native Arch Linux ARM.

This is a **development port in early hardware bring-up**, not a flashable image or a finished daily-driver release. Nothing on this page is a claim about a device that has booted this port; every component states its basis instead.

## Where each piece comes from

- **Inherited from omarchy-apollo, device-agnostic and validated there:** the app grid, wvkbd touch keyboard and its lifecycle, the display controller, the trusted PIN lock/keypad and numeric sudo/polkit administration, the power-button presentation, the Waydroid Android stack (VANILLA/GAPPS chooser, APK installer, lifecycle client), the clock calibration helper, the update guards, and the Quickshell/Hyprgraphics fixes. These carry the apollo project's test records; no result from there transfers automatically to this device.
- **New for lmi, community basis:** the kernel. `hardware/lmi-base/port-source/linux-lmi/` builds the yuweiyuan8 v6.19 close-to-mainline tree (pinned commit, sha512 pin pending first verified download), which carries the `sm8250-xiaomi-lmi` device tree, the Samsung AMS667UU01 AMOLED panel driver and the FocalTech FTS touch driver. Boot, display, touch, GPU, Wi-Fi, Bluetooth, NFC and sensors are reported working by the community forks and the postmarketOS wiki page; this port has not reproduced any of it yet.
- **Device-private, pending extraction:** remote-processor firmware (ADSP/CDSP/SLPI), the device zap shader, the SLPI sensor registry and modem files, extracted from the unlocked phone. Their sha512 pins are explicit `SKIP` markers until that happens.
- **Open fronts, no current path:** modem calls/SMS/data (SDX55m has no mainline QMI), GPS, the Goodix under-display fingerprint reader, haptics, the pop-up camera motor and USB-C video. Cameras are deliberately stubbed until kernel bring-up (M3).

## Milestones

1. **M1** — kernel, boot image, firmware extraction, first flash: cold boot, 60 Hz display, touch, GPU, Wi-Fi.
2. **M2** — sensors/rotation, audio (WCD9380 + TFA9874 UCM), clock restore cycle.
3. **M3** — camera bring-up and the libcamera integration pattern ported from apollo.
4. **Then** — rerun the inherited PIN/lock, keyboard and Waydroid suites on the device; open fronts tracked honestly.

The detailed matrix and checklists: [hardware status](hardware/lmi-base/docs/status.md).

## Explore the project

[Architecture](docs/architecture.md) · [Roadmap](docs/roadmap.md) · [Android](docs/android.md) · [Keyboard](docs/keyboard.md) · [Display](docs/display.md) · [Clock](docs/clock.md) · [Build](docs/build.md) · [Updates](docs/updates.md) · [Contributing](CONTRIBUTING.md) · [Security and privacy](SECURITY.md)

`platform/`, `config/` and `lock/` contain the mobile integration inherited from apollo. `hardware/lmi-base/` is the lmi device layer. `patches/` adapts pinned Omarchy. `packaging/` holds component recipes and `tests/` the reproducible checks. `PROVENANCE.md` records every upstream source and what was inherited versus newly written.

Firmware binaries, personalized images, partition backups, private diagnostics, network names and credentials are excluded. This is source for a development port, not a generic flashable ARM ISO.

## Upstream software and licensing

Apollo's mobile integration is developed in the omarchy-apollo project and inherited here under its license. The underlying software retains its own authorship and licenses: [Omarchy](https://github.com/omacom/omarchy), [Arch Linux ARM](https://archlinuxarm.org/), [Hyprland](https://github.com/hyprwm/Hyprland), [Quickshell](https://github.com/quickshell-mirror/quickshell), [Waydroid](https://github.com/waydroid/waydroid), the [yuweiyuan8/linux](https://github.com/yuweiyuan8/linux) close-to-mainline kernel tree, Linux, and the lmi/apollo device-port contributors. Proprietary Xiaomi firmware is not redistributed.
