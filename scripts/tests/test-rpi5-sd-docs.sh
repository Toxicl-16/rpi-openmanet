#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
doc="$repo/docs/SD_CARD_RESIZE.md"

grep -F 'macOS' "$doc" >/dev/null
grep -F 'Native Linux' "$doc" >/dev/null
grep -F 'resizepart 2 100%' "$doc" >/dev/null
grep -F 'unsquashfs -s' "$doc" >/dev/null
grep -F 'fsck.f2fs -f' "$doc" >/dev/null
grep -F 'resize.f2fs' "$doc" >/dev/null
grep -F 'firmware does not perform either operation automatically' "$doc" >/dev/null

echo 'PASS: manual SD-card expansion documentation checks'
