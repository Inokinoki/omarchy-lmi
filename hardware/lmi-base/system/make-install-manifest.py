#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0-only
"""Generate the install manifest consumed by install-persistent.

Host-side tool: hashes the built base SquashFS and boot image into the
{"base": {...}, "boot": {...}, "userdata_size": N} shape install-persistent
verifies against the actual files and partition. userdata_size is the exact
byte size of the phone's userdata partition; take it from the
'userdata_bytes' field of install-persistent's read-only preflight output
and pass it here, or patch it into the manifest afterwards.
"""
from pathlib import Path
import argparse
import hashlib
import json

p = argparse.ArgumentParser()
p.add_argument('--base', type=Path, required=True)
p.add_argument('--boot', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--userdata-size', type=int, default=0,
               help='exact userdata partition size in bytes (from preflight)')
a = p.parse_args()

def entry(path):
    with path.open('rb') as f:
        digest = hashlib.file_digest(f, 'sha256').hexdigest()
    return {'sha256': digest, 'size': path.stat().st_size}

manifest = {
    'base': entry(a.base),
    'boot': entry(a.boot),
    'userdata_size': a.userdata_size,
}
a.output.write_text(json.dumps(manifest, indent=2) + '\n')
if not a.userdata_size:
    print('NOTE: userdata_size is 0; run install-persistent preflight on the '
          'device and fill it from userdata_bytes before installing.')
print(f'MANIFEST COMPLETE: {a.output}')
