# lmi hardware status

POCO F2 Pro (`lmi`, M2004J11G, also Redmi K30 Pro), Qualcomm SM8250 "kona",
Adreno 650. This matrix states, for each component, where the current
expectation comes from. It is a development port: **no component here has
been accepted on the device yet**. Sources are named so each claim can be
re-checked; "community" means the close-to-mainline forks and the
postmarketOS wiki page for xiaomi-lmi, not this project's own evidence.

| Component | Basis | Status for this port |
| --- | --- | --- |
| Boot (Android boot image, UFS, USB) | community forks boot a distro rootfs | Kernel payload expected to work; this project's SquashFS/slot layout is untested — M1 |
| Display (Samsung AMS667UU01 AMOLED, 60 Hz) | community: works | Panel driver + DTS are in the pinned kernel; brightness-glitch artifact reported upstream — verify at M1 |
| Touch (FocalTech FTS, i2c13) | community: works | Driver in pinned kernel; finger mapping/rotation — M1 |
| GPU (Adreno 650, freedreno) | community: works; firmware upstream | Expected off the shelf; zap shader device-extracted — M1 |
| Wi-Fi (QCA6390, ath11k) | community: works; firmware upstream | M1 after first boot |
| Bluetooth (QCA6390, uart6) | community: works | M1 |
| Sensors (accel/mag/light via SLPI + hexagonrpcd/libSSC) | community: works | Same architecture as apollo; needs lmi `slpi.mbn` + sensor registry — M2 |
| Audio (WCD9380 + TFA9874 amp) | community: works with quirks | UCM and amp config not written yet — M2 |
| NFC (NXP pn553) | community: works | Untested here — opportunistic |
| Cameras (IMX686 + popup front, …) | community: OV13B10 raw only | **Not brought up.** Stub confs and pending check — M3 |
| Modem (SDX55m) | community: enumerates, no QMI | Integration inherited from apollo, marked pending; no calls/SMS/data expected — open |
| GPS | community: broken | Open |
| Fingerprint (Goodix under-display FOD) | no mainline support | Open (hardest item) |
| Haptics (aw8697) | community: broken | Open |
| Pop-up camera motor (drv8846) | downstream only | Open |
| IR blaster | community: ir-spi-led | Untested here — opportunistic |

## M1 on-device checklist (boot, display, touch, GPU, Wi-Fi)

1. Cross-compile with `hardware/lmi-base/port-source/linux-lmi/build-kernel.sh`
   on an aarch64-capable Linux host (or in a container), after pinning the
   tarball sha512 (`LMI_TARBALL_SHA512`). The CI `kernel` job produces the
   same payload plus the packaged assets tarball.
2. Extract device firmware into `packaging/firmware-model/`'s private-input
   tarball; fill the `SKIP` sha512 pins in `packaging/firmware.PKGBUILD`,
   `lmi-dsp` and `lmi-modem` PKGBUILDs.
3. Unpack the stock lmi boot.img (`unpack_bootimg.py --boot_img stock.img`)
   and compare header base/offsets and the bootloader command line against
   `hardware/lmi-base/system/build-bootimg.sh` defaults; adjust the script
   if they differ.
4. Read `/sys/firmware/devicetree/base/model` on the booted kernel and fix
   the model assert in `hardware/lmi-base/system/install-persistent` if the
   string differs from `POCO F2 Pro`.
5. Build the real base SquashFS (Arch Linux ARM aarch64 rootfs + device
   packages + private firmware inputs), then assemble the initramfs with
   `build-initramfs.sh` (it bakes the base checksum) and the boot image with
   `build-bootimg.sh`; `fastboot boot` the image first, then flash `boot`
   and an empty `dtbo`, with a preserved recovery route.
6. Accept: cold boot to compositor, panel at 60 Hz, FocalTech touch across
   rotation, freedreno GL, ath11k scan/join on both bands, and the
   fatal-path reboot into the bootloader.

## M2 checklist (sensors, audio, clock)

6. Verify SLPI sensors via iio-sensor-proxy and the display controller's
   automatic rotation.
7. Write the WCD9380/TFA9874 UCM (start from the fork's known quirks:
   `<&swr2 1>` capture port, inverted EAR_PA), accept speaker/earpiece/mic.
8. Accept the PMIC clock restore cycle (inherited helper, same PM8150 family).

## M3 checklist (cameras)

9. Bring up CAMSS for the wired sensor set, then port the apollo
   libcamera-integration pattern: per-sensor naming rules, tuning files and
   the stream check with real lmi node names.
