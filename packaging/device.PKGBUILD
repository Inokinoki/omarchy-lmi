# Build in a staging copy of this repository. No credentials are packaged.
pkgname=omarchy-lmi-device
pkgver=0.1.0
pkgrel=6
pkgdesc='Clean-image device services and initial owner setup for Omarchy LMI'
arch=('aarch64')
license=('MIT' 'GPL-2.0-only')
depends=('omarchy-lmi-mobile>=0.1.0-10' 'omarchy-lmi-lock>=0.1.0-3'
  'python' 'python-gobject' 'gtk4' 'systemd' 'networkmanager' 'openssh' 'sudo' 'zenity')
options=('!strip' '!debug')
package() {
  local files="$startdir/hardware/lmi-base/system"
  install -Dm755 "$files/lmi-usb-gadget.py" "$pkgdir/usr/local/sbin/lmi-usb-gadget"
  install -Dm644 "$files/lmi-usb-gadget.service" "$pkgdir/usr/lib/systemd/system/lmi-usb-gadget.service"
  install -Dm644 "$files/70-lmi-usb-gadget.rules" "$pkgdir/usr/lib/udev/rules.d/70-lmi-usb-gadget.rules"
  install -Dm644 "$files/20-lmi-usb.network" "$pkgdir/usr/lib/systemd/network/20-lmi-usb.network"
  install -Dm644 "$files/20-lmi-usb-unmanaged.conf" "$pkgdir/usr/lib/NetworkManager/conf.d/20-lmi-usb-unmanaged.conf"
  install -Dm644 "$files/60-lmi-usb-ssh.conf" "$pkgdir/etc/ssh/sshd_config.d/60-lmi-usb-ssh.conf"
  install -Dm644 "$files/30-lmi-sshd-usb-retry.conf" "$pkgdir/usr/lib/systemd/system/sshd.service.d/30-lmi-usb-retry.conf"
  for component in firstboot-password firstboot-pin password-dialog owner-pin-setup pin-ready-lock enable-pin-administration; do
    install -Dm755 "$startdir/platform/omarchy-lmi-$component" "$pkgdir/usr/lib/omarchy/lmi/$component"
  done
  install -Dm644 "$startdir/platform/omarchy-lmi-owner-pin-setup.service" "$pkgdir/usr/lib/systemd/system/omarchy-lmi-owner-pin-setup.service"
  install -Dm644 "$startdir/platform/omarchy-lmi-pin-ready-lock.service" "$pkgdir/usr/lib/systemd/system/omarchy-lmi-pin-ready-lock.service"
  install -Dm644 "$startdir/platform/omarchy-lmi-owner-setup.service" "$pkgdir/usr/lib/systemd/user/omarchy-lmi-owner-setup.service"
  install -Dm755 "$startdir/platform/omarchy-lmi-setup" "$pkgdir/usr/bin/omarchy-lmi-setup"
  install -Dm644 "$startdir/platform/omarchy-lmi-setup.desktop" "$pkgdir/usr/share/applications/omarchy-lmi-setup.desktop"
  install -Dm755 "$startdir/platform/omarchy-lmi-clock" "$pkgdir/usr/lib/omarchy/lmi/clock"
  for unit in clock-restore.service clock-save.service clock-save.timer; do
    install -Dm644 "$startdir/platform/omarchy-lmi-$unit" "$pkgdir/usr/lib/systemd/system/omarchy-lmi-$unit"
  done
  install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
