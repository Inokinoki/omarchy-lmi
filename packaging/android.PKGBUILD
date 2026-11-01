pkgname=omarchy-lmi-android
pkgver=0.1.0
pkgrel=10
pkgdesc='On-demand Android integration and installer flavor selection for LMI'
arch=('aarch64')
license=('MIT')
depends=('omarchy-lmi' 'waydroid' 'lxc' 'python-dbus' 'python-gobject' 'gtk4' 'util-linux' 'libnotify' 'xdg-utils' 'polkit' 'zenity')
options=('!strip' '!debug')
package() {
  install -Dm644 "$startdir/platform/var-lib-waydroid.mount" "$pkgdir/usr/lib/systemd/system/var-lib-waydroid.mount"
  install -Dm644 "$startdir/platform/waydroid-lmi-storage.conf" "$pkgdir/usr/lib/systemd/system/waydroid-container.service.d/50-lmi-storage.conf"
  install -Dm755 "$startdir/platform/omarchy-lmi-android" "$pkgdir/usr/bin/omarchy-lmi-android"
  install -Dm644 "$startdir/platform/omarchy-lmi-android.desktop" "$pkgdir/usr/share/applications/omarchy-lmi-android.desktop"
  install -Dm644 "$startdir/platform/omarchy-lmi-apk-install.desktop" "$pkgdir/usr/share/applications/omarchy-lmi-apk-install.desktop"
  install -Dm755 "$startdir/platform/omarchy-setup-lmi-android" "$pkgdir/usr/bin/omarchy-setup-lmi-android"
  install -Dm755 "$startdir/platform/omarchy-lmi-initialize-android" "$pkgdir/usr/lib/omarchy/lmi/initialize-android"
  install -Dm755 "$startdir/platform/omarchy-lmi-select-android" "$pkgdir/usr/bin/omarchy-lmi-select-android"
  install -Dm755 "$startdir/platform/omarchy-lmi-install-android" "$pkgdir/usr/bin/omarchy-lmi-install-android"
  install -Dm644 "$startdir/platform/omarchy-lmi-install-android.desktop" "$pkgdir/usr/share/applications/omarchy-lmi-install-android.desktop"
  install -Dm644 "$startdir/config/install/android-flavors.json" "$pkgdir/usr/share/omarchy-lmi-android/install/android-flavors.json"
  for component in apk-service android-client; do
    install -Dm755 "$startdir/platform/$component" "$pkgdir/usr/lib/omarchy/lmi/$component"
  done
  install -Dm644 "$startdir/platform/omarchy-lmi-apk.service" "$pkgdir/usr/lib/systemd/system/omarchy-lmi-apk.service"
  install -Dm644 "$startdir/platform/org.omarchy.Lmi.Android.service" "$pkgdir/usr/share/dbus-1/system-services/org.omarchy.Lmi.Android.service"
  install -Dm644 "$startdir/platform/org.omarchy.Lmi.Android.conf" "$pkgdir/usr/share/dbus-1/system.d/org.omarchy.Lmi.Android.conf"
  install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
