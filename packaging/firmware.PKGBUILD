# Local image-build input only. Proprietary archives are not stored in the repo.
pkgname=lmi-device-firmware
pkgver=0.1.0
pkgrel=1
pkgdesc='POCO F2 Pro (lmi) model firmware for local device image builds'
arch=('any')
url='https://github.com/yuweiyuan8/firmware-xiaomi-lmi'
license=('LicenseRef-proprietary')
depends=('linux-firmware-qcom')
options=('!strip' '!debug')
# The firmware tarball is extracted from an unlocked POCO F2 Pro by the owner
# (M1 checklist in docs/status.md). Pin its sha512 here once it exists; SKIP
# is an explicit pending marker, not a permanent state.
source=(
  "firmware-xiaomi-lmi-0.1.tar.gz::file://$startdir/private-inputs/firmware-xiaomi-lmi-0.1.tar.gz")
sha512sums=('SKIP')  # pending M1 device extraction
package() {
  while IFS= read -r name; do
    [[ -n $name && $name != \#* ]] || continue
    # Linux searches firmware/updates before the generic firmware directory.
    # Keep the extracted device variants without taking ownership of files
    # provided by linux-firmware-qcom.
    case "$name" in
      qcom/sm8250/xiaomi/lmi/a650_zap.mbn)
        install -Dm644 "$srcdir/$name" "$pkgdir/usr/lib/firmware/updates/$name" ;;
      *) install -Dm644 "$srcdir/$name" "$pkgdir/usr/lib/firmware/$name" ;;
    esac
  done < "$startdir/packaging/firmware-model/files.txt"
  # Device-specific modem identity is extracted privately into RAM at runtime.
  # It is never an input to this firmware package or the public source tree.
  ! find "$pkgdir" -type f \( -name 'efs1.bin' -o -name 'efs2.bin' -o -name 'efs3.bin' -o -name 'modemst1' -o -name 'modemst2' \) -print | grep .
}
