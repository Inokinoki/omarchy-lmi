# lmi-base

Device bring-up layer for the POCO F2 Pro (`lmi`). It mirrors the layout of
the apollo project's `hardware/apollo-base` so the two ports stay comparable:
`port-source/` holds kernel/packaging inputs, `system/` the boot and
maintenance scripts, `docs/` the hardware status and checklists.

What is inherited from the apollo port (renamed, logic unchanged): the
Qualcomm userspace packages (`lmi-qcom-core`, `pd-mapper-lmi`,
`libssc-lmi`, `iio-sensor-proxy-lmi`, `modemmanager-lmi`,
`lmi-bluetooth-address`, `lmi-location`, `lmi-video`, `lmi-dsp`,
`lmi-modem`) and the USB maintenance stack in `system/`. The sensor stack is
architecturally identical (SSC over hexagonrpcd + libssc, iio-sensor-proxy
on top); lmi needs its own `slpi.mbn` and sensor registry, extracted on the
device.

What is new for this port: `port-source/linux-lmi/` builds the
yuweiyuan8 v6.19 close-to-mainline kernel carrying the `sm8250-xiaomi-lmi`
device tree, the Samsung AMS667UU01 panel driver and the FocalTech FTS
touch driver. No kernel patches are carried initially; the build script
keeps the apollo idempotent-patch pattern for SoC-level fixes if they turn
out to be needed.

What is deliberately absent: the apollo camera stack (different sensors;
M3), the apollo audio UCM and Cirrus amp firmware (different amplifier;
M2 — see `port-source/lmi-board-data/README.md`), the fingerprint work
(different reader, no mainline support), and the historical KDE-era helpers.

Proprietary inputs (firmware tarballs, sensor registry, modem files) are
device-private. Their sha512 pins in the PKGBUILDs are explicit `SKIP`
markers until the owner extracts them from the unlocked device; see
docs/status.md for the M1 checklist.
