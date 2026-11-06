#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
board="$repo/boards/ekh-bcm2710/target_diffconfig"
pkg="$repo/package/iwfcam-rtsp"

grep -F 'CONFIG_TARGET_bcm27xx_bcm2710_DEVICE_rpi-3=y' "$board" >/dev/null
grep -F 'CONFIG_PACKAGE_iwfcam-rtsp=y' "$board" >/dev/null
grep -F 'PKG_SOURCE_VERSION:=5fd29cbef24c8f834542bc0afb3f44ec0f4e4243' "$pkg/Makefile" >/dev/null
grep -F 'camera_mac' "$pkg/files/iwfcam.config" >/dev/null
grep -F 'station dump' "$pkg/files/iwfcam-wait" >/dev/null
grep -F 'ip neigh show' "$pkg/files/iwfcam-wait" >/dev/null
grep -F 'procd_set_param command "$WAIT_BIN"' "$pkg/files/iwfcam.init" >/dev/null
test -s "$pkg/patches/100-h264-annexb.patch"
sh -n "$pkg/files/iwfcam.init" "$pkg/files/iwfcam-wait"

echo 'PASS: Pi 3B+ IWFCam package and MAC-gated startup checks'
