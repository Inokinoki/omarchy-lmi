#!/bin/bash
# Assemble the private firmware-input tarball consumed by
# packaging/firmware.PKGBUILD (private-inputs/firmware-xiaomi-lmi-0.1.tar.gz).
#
#   --output PATH       tarball to write (required)
#   --source MODE       community (default): clone the pinned
#                       yuweiyuan8/firmware-xiaomi-lmi commit
#                       device: use the owner's own extracted firmware tree
#   --device-dir PATH   with --source device: a directory holding the
#                       qcom/sm8250/xiaomi/lmi/... layout
#   --scratch DIR       scratch directory (default mktemp)
#
# The packaged file list is packaging/firmware-model/files.txt, verified one
# for one against the source. Modem identity files (EFS, modemst) abort the
# assembly: they are never an input to this tree.
set -euo pipefail
COMMIT=dde156380b2ac372619ed332dbe60640b838b7fe
here=$(cd "$(dirname "$0")" && pwd)
list="$here/files.txt"
output='' source=community device_dir='' scratch=''
while [ $# -gt 0 ]; do
    case "$1" in
        --output) output=$2; shift 2 ;;
        --source) source=$2; shift 2 ;;
        --device-dir) device_dir=$2; shift 2 ;;
        --scratch) scratch=$2; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[ -n "$output" ] || { echo "--output required" >&2; exit 2; }
[ -f "$list" ] || { echo "files.txt missing: $list" >&2; exit 2; }
work=${scratch:-$(mktemp -d)}
cleanup() { [ -n "$scratch" ] || rm -rf "$work"; }
trap cleanup EXIT

case "$source" in
    community)
        fw="$work/fw"
        git init -q "$fw"
        git -C "$fw" remote add origin https://github.com/yuweiyuan8/firmware-xiaomi-lmi
        git -C "$fw" fetch -q --depth 1 origin "$COMMIT"
        git -C "$fw" checkout -q FETCH_HEAD
        src="$fw/lib/firmware"
        ;;
    device)
        [ -n "$device_dir" ] || { echo "--device-dir required with --source device" >&2; exit 2; }
        src=$(cd "$device_dir" && pwd)
        ;;
    *) echo "--source must be community or device" >&2; exit 2 ;;
esac

staging="$work/staging"
copied=0
while IFS= read -r name; do
    [[ -n $name && $name != \#* ]] || continue
    f="$src/$name"
    [ -f "$f" ] || { echo "missing firmware file: $name" >&2; exit 1; }
    mkdir -p "$staging/$(dirname "$name")"
    cp "$f" "$staging/$name"
    copied=$((copied + 1))
done < "$list"
echo "packaged $copied files per files.txt"
# Warn (not fail) about extras present in the source set.
found=$(find "$staging" -type f | wc -l)
if [ "$found" -ne "$copied" ]; then
    echo "warning: $found files staged but $copied listed; extras will not be installed" >&2
fi
# Identity files never travel through this tree.
if find "$staging" -type f \( -name 'efs*' -o -name 'modemst*' \) | grep -q .; then
    echo 'refusing: modem identity files present in the source set' >&2
    exit 1
fi
# Deterministic archive: sorted entries, fixed metadata, no gzip timestamp.
# The pinned sha512 in packaging/firmware.PKGBUILD is only reproducible with
# these flags.
tar --sort=name --mtime=@0 --owner=0:0 --group=0 -cf - -C "$staging" qcom \
    | gzip -n > "$output"
echo "FIRMWARE TARBALL COMPLETE: $output"
sha512sum "$output"
echo "Fill this hash into packaging/firmware.PKGBUILD sha512sums (replacing SKIP)."
