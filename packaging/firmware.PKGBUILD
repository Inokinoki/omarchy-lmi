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
# The firmware tarball is assembled from the pinned community
# device-extracted set (see packaging/firmware-model/files.txt for the
# commit) or extracted from an unlocked POCO F2 Pro by the owner (M1
# checklist in hardware/lmi-base/docs/status.md). Pin its sha512 here once
# it exists; SKIP is an explicit pending marker, not a permanent state.
source=(
  "firmware-xiaomi-lmi-0.1.tar.gz::file://$startdir/private-inputs/firmware-xiaomi-lmi-0.1.tar.gz")
sha512sums=('0b59ca68a41fd0495470e6b0bf0659ac119acabdf740bab5402a9cb434de6fbee04a99dbdc06ff4bcdbae0238a448ee079dc399fc993f2010a0d8c671e63d4b4')  # assembled from the pinned community commit; re-verify against the device extraction at M1
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
