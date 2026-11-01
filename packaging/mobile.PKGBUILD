# Copy this recipe to PKGBUILD inside a staging copy of this repository.
pkgname=omarchy-lmi-mobile
pkgver=0.1.0
pkgrel=13
pkgdesc='Mobile input and display orientation controls for Omarchy LMI'
arch=('aarch64')
license=('MIT')
depends=('omarchy-lmi' 'wvkbd-mobintl-lmi>=0.20-2' 'gst-plugin-pipewire' 'python-dbus' 'python-gobject' 'gtk4')
options=('!strip' '!debug')
package() {
  install -d "$pkgdir/usr/share/omarchy-lmi-mobile"
  cp -a "$startdir/config" "$pkgdir/usr/share/omarchy-lmi-mobile/"
  install -Dm755 "$startdir/platform/omarchy-lmi-keyboard-toggle" "$pkgdir/usr/bin/omarchy-lmi-keyboard-toggle"
  install -Dm755 "$startdir/platform/omarchy-lmi-keyboard-run" "$pkgdir/usr/bin/omarchy-lmi-keyboard-run"
  install -Dm644 "$startdir/platform/omarchy-lmi-keyboard.service" "$pkgdir/usr/lib/systemd/user/omarchy-lmi-keyboard.service"
  install -Dm755 "$startdir/platform/omarchy-lmi-pin-ready-keyboard" "$pkgdir/usr/lib/omarchy/lmi/pin-ready-keyboard"
  install -Dm644 "$startdir/platform/omarchy-lmi-pin-ready-keyboard.service" "$pkgdir/usr/lib/systemd/system/omarchy-lmi-pin-ready-keyboard.service"
  install -Dm644 "$startdir/platform/omarchy-lmi-owner-pin-keyboard.conf" "$pkgdir/usr/lib/systemd/system/omarchy-lmi-owner-pin-setup.service.d/20-keyboard.conf"
  install -Dm644 "$startdir/platform/omarchy-lmi-public-status.conf" "$pkgdir/usr/lib/tmpfiles.d/omarchy-lmi-public-status.conf"
  install -Dm755 "$startdir/platform/omarchy-lmi-power-button" "$pkgdir/usr/bin/omarchy-lmi-power-button"
  install -Dm644 "$startdir/platform/omarchy-lmi-startup-lock.service" "$pkgdir/usr/lib/systemd/user/omarchy-lmi-startup-lock.service"
  install -Dm644 "$startdir/platform/omarchy-lmi-power.conf" "$pkgdir/usr/lib/systemd/logind.conf.d/40-omarchy-lmi-power.conf"
  install -Dm755 "$startdir/platform/omarchy-lmi-display" "$pkgdir/usr/bin/omarchy-lmi-display"
  install -Dm644 "$startdir/platform/omarchy-lmi-display.service" "$pkgdir/usr/lib/systemd/user/omarchy-lmi-display.service"
  install -Dm644 "$startdir/platform/org.omarchy.Lmi.Display.service" "$pkgdir/usr/share/dbus-1/services/org.omarchy.Lmi.Display.service"
  install -Dm644 "$startdir/platform/omarchy-lmi-display.desktop" "$pkgdir/usr/share/applications/org.omarchy.Lmi.DisplaySettings.desktop"
  install -Dm644 "$startdir/config/wireplumber/90-omarchy-lmi-cameras.conf" "$pkgdir/usr/share/wireplumber/wireplumber.conf.d/90-omarchy-lmi-cameras.conf"
  install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
