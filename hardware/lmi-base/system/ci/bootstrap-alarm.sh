#!/bin/bash
# Import the official Arch Linux ARM aarch64 bootstrap as the docker image
# alarm-base, after verifying its detached signature against the pinned
# Arch Linux ARM build-system key. Run on a native aarch64 host.
set -euo pipefail
FPR=68B3537F39A313B3E574D06777193F152BDBE6A6
url=http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl --fail --location --retry 3 -o "$work/alarm.tar.gz" "$url"
curl --fail --location --retry 3 -o "$work/alarm.tar.gz.sig" "$url.sig"
export GNUPGHOME="$work/gnupg"
install -dm700 "$GNUPGHOME"
gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$FPR"
gpg --batch --status-fd 1 --verify "$work/alarm.tar.gz.sig" "$work/alarm.tar.gz" \
    | grep -q "^\[GNUPG:\] VALIDSIG $FPR " \
    || { echo "signature not made by $FPR" >&2; exit 1; }
# /etc/resolv.conf in the bootstrap is a dangling symlink that docker cannot
# bind-mount over; replace just that entry.
python3 -I - "$work/alarm.tar.gz" "$work/alarm.tar" <<'PY'
import io, sys, tarfile
src, dst = sys.argv[1:3]
with tarfile.open(src, 'r:gz') as i, tarfile.open(dst, 'w', format=tarfile.PAX_FORMAT) as o:
    for m in i:
        if m.name in ('./etc/resolv.conf', 'etc/resolv.conf'):
            n = tarfile.TarInfo(m.name); n.mode = 0o644; n.mtime = m.mtime
            o.addfile(n, io.BytesIO(b''))
        else:
            o.addfile(m, i.extractfile(m) if m.isreg() else None)
PY
docker import --platform linux/arm64 "$work/alarm.tar" alarm-base:latest
