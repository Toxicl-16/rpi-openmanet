#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
board="$repo/boards/ekh-bcm2712/target_diffconfig"
patch="$repo/patches/build-fixes/014-dockerd-f2fs-vfs-config.patch"

grep -F 'CONFIG_KERNEL_F2FS_FS_SECURITY=y' "$board" >/dev/null
grep -F 'CONFIG_PACKAGE_libcap-bin=y' "$board" >/dev/null
grep -F 'storage-driver' "$patch" >/dev/null
grep -F "storage_driver 'vfs'" "$patch" >/dev/null
grep -F 'security.capability' "$patch" >/dev/null
grep -F '014-dockerd-f2fs-vfs-config.patch' "$repo/scripts/apply-build-fixes.sh" >/dev/null

echo 'PASS: OpenMANET Docker/F2FS source checks'
