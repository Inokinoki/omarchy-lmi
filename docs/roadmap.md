# Roadmap

The detailed hardware matrix and per-milestone checklists live in
[hardware status](../hardware/lmi-base/docs/status.md). In brief:

1. **M1 — base up.** Cross-build the pinned yuweiyuan8 v6.19 kernel, extract
   device firmware from the unlocked phone, assemble the Android boot image
   and the SquashFS/overlay root, flash with a preserved recovery route, and
   accept cold boot, 60 Hz display, FocalTech touch, freedreno GPU and
   ath11k Wi-Fi on the device.
2. **M2 — input, sensors, sound, time.** Accept automatic rotation through
   the real accelerometer (SLPI + libssc with the lmi registry), write the
   WCD9380/TFA9874 UCM and accept speaker/earpiece/microphone, and validate
   the inherited PMIC clock restore cycle.
3. **M3 — cameras.** Bring up CAMSS for the wired sensor set, port the
   apollo libcamera integration pattern (naming rules, tuning, stream
   check) with real lmi node names, replacing the pending stubs.
4. **Then — phone maturity.** Rerun the inherited PIN/lock, keyboard and
   Waydroid suites on the device; add failure, suspend/resume and
   long-duration coverage; physical file-manager, notification and touch
   navigation acceptance for Android.
5. **Open fronts** (no current path, tracked honestly): modem calls/SMS/data
   (SDX55m without QMI), GPS, Goodix under-display fingerprint, aw8697
   haptics, pop-up camera motor, USB-C video.
6. **System updates.** Implement and validate a coherent LMI
   update/rollback workflow with matching boot images; until then the
   device-stack guard and stopped PC updater remain the protection.
7. **Publication.** A tested installation/recovery procedure and release
   artifacts after repeatable device validation; single accepted boots do
   not make a stock-device installer.

"100% functional" is the target, not a claim about the current build.
Hardware limits and failed tests stay visible.
