# Display controls for a phone

Open **Pantalla LMI** from the application launcher. The installed mobile profile adds manual orientation, automatic rotation, a rotation lock and refresh-rate selections. The lmi panel is a Samsung AMS667UU01 AMOLED advertising 60 Hz; the controller offers that single mode until another panel mode is proven on the device.

While the trusted PIN-creation surface is active, display changes return `LMI_PIN_SETUP_ACTIVE`. This guard was exercised against the installed service: the panel geometry, refresh, touch configuration and PIN process were preserved. Complete enrollment on the phone before trying the controls; do not share the PIN.

## Orientation and keyboard

The controller changes the compositor's monitor transform and touch transform together. It offers portrait, inverted portrait, both landscape directions, automatic rotation and a lock which preserves the current orientation. Automatic mode claims the real system accelerometer; choosing a manual orientation releases that claim. Sensor changes are debounced, and invalid or undefined readings do not select a new transform.

The service uses sensor and compositor events rather than a polling loop. It restores saved choices after a compositor configuration reload or service restart. The default configuration holds no accelerometer claim and changes no panel setting. Display preferences contain only orientation and refresh choices, in a private per-user state file. A failed preference write restores the previous monitor and touch configuration.

The keyboard profile reserves 300 logical pixels in portrait and 180 in landscape. Both sizes were measured from the real wvkbd layer in the isolated compositor test. Mobile revision 9 adds automatic text-input integration after PIN enrollment, while preserving the bar button for manual control. It stays hidden in manual mode while the PIN-creation surface is open. See the separate [19-check keyboard record and limits](keyboard.md).

## Commands

Use these in the native desktop session, without sudo:

```sh
omarchy-lmi-display settings
omarchy-lmi-display status
omarchy-lmi-display orientation auto
omarchy-lmi-display orientation lock
omarchy-lmi-display orientation portrait
omarchy-lmi-display orientation landscape-left
omarchy-lmi-display refresh 60
```

The GUI presents the same controls as the CLI and keeps a touch-sized **Cerrar** button in its header. Its desktop entry matches the GTK application ID. Refresh changes are accepted only for a mode advertised by the target panel. No measured battery-life improvement is claimed. Physical refresh switching remains to be acceptance-tested.

## Device checks and limits

The display controller, D-Bus client, GTK window, compositor and keyboard plumbing are inherited unchanged from the validated omarchy-apollo integration, where they passed a 23-check isolated-compositor record against the real accelerometer. No lmi device record exists yet: nothing here has run against the POCO F2 Pro panel, touch controller or accelerometer.

Run on the device from the local desktop account once the base is installed:

```sh
systemd-run --user --wait --pipe --collect \
  python -I /path/to/omarchy-lmi/tests/check_display_controls.py
```

This uses the desktop user's normal service context for the sensor policy. The test itself creates a private session bus. The optional `kwin` test tool is needed in addition to the installed mobile stack.

Physical automatic rotation, finger accuracy after rotation, application behavior in landscape, refresh switching and battery measurements remain pending. New-session cold boot and real PIN unlocking are separate acceptance gates.
