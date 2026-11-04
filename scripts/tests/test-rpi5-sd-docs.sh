#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
doc="$repo/docs/rpi5-sd-card-expansion.md"

grep -F 'macOS with a Linux VM' "$doc" >/dev/null
grep -F 'Linux procedure' "$doc" >/dev/null
grep -F 'resizepart 2 100%' "$doc" >/dev/null
grep -F 'bytes_used' "$doc" >/dev/null
grep -F 'fsck.f2fs -f' "$doc" >/dev/null
grep -F 'resize.f2fs' "$doc" >/dev/null
grep -F 'does **not** resize partitions' "$doc" >/dev/null

echo 'PASS: manual SD-card expansion documentation checks'
