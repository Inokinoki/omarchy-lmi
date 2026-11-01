#!/usr/bin/python3
"""Camera stream check for the POCO F2 Pro (lmi). PENDING until M3.

The apollo project validates its camera integration by capturing and
discarding real PipeWire buffers from every named libcamera source. This
port has no camera bring-up yet: the wired sensor set on lmi is unknown
and no node names have been observed on the device. There is nothing
honest to assert here, so this check refuses to run rather than
pretending to pass.
"""
import json
import sys

RESULT = {
    'check': 'camera_streams',
    'device': 'lmi',
    'status': 'pending',
    'reason': ('camera bring-up has not happened for this port; the wired '
               'sensor set and libcamera node names are unknown until the '
               'kernel work lands'),
}

if __name__ == '__main__':
    print(json.dumps(RESULT))
    sys.exit(2)
