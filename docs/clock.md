# Read-only PMIC clock calibration

The phone's `rtc-pm8xxx` counter can be read, but the running device tree supplies neither permission for direct host writes nor a persistent kernel offset provider. RTC set requests return `ENODEV`. The port does not enable a firmware property merely to suppress this error.

`platform/omarchy-lmi-clock` pairs that counter with trusted UTC and stores a root-only calibration in `/var/lib/omarchy-lmi/clock/`. At boot it predicts UTC from the elapsed counter. It writes no RTC register, modem time store, UEFI variable or firmware partition.

Restore runs after local filesystems and before `time-set.target`/`sysinit.target`. A timer attempts calibration after boot and every fifteen minutes, saving only if systemd reports synchronized network time. An administrator may explicitly supply trusted UTC for an offline initial calibration; the tested installation used the maintenance host as this reference.

The helper rejects a changed RTC, decreasing/wrapped counter, expired calibration, malformed data and unsafe permissions. Calibration lasts at most 366 days and is written atomically with file/directory synchronization. The restore service holds only the time-setting capability; refresh holds none. Normal network time synchronization remains available when calibration is absent or invalid.

Twelve fixture cases cover elapsed-time arithmetic, reset/wrap, expiry, device changes, invalid inputs, epoch bounds, atomic private storage and symlink/permission rejection. They are device-independent and can run anywhere with `python -I tests/check_readonly_clock.py`; they do not change a real clock. The same helper succeeded against the actual PMIC counter on the apollo device, with predicted and system UTC within two seconds. **That is not an lmi result**: the same PM8150-family RTC is present here, but the restore cycle needs its own acceptance after M1.

**Pending:** everything on lmi. The first acceptance steps are a complete power-off after calibration, an unplugged boot and a comparison against trusted UTC. PMIC continuity, offline accuracy, alarms and suspend reliability are not yet claimed for this device.
