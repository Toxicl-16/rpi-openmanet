#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
board="$repo/boards/ekh-bcm2712/target_diffconfig"
script="$repo/package/openmanet-batman-fix/files/usr/sbin/openmanet-batman"

grep -F 'CONFIG_PACKAGE_openmanet-batman-fix=y' "$board" >/dev/null
grep -F "routing_algo='BATMAN_V'" "$script" >/dev/null
grep -F "proto='batadv_hardif'" "$script" >/dev/null
grep -F "master='bat0'" "$script" >/dev/null
grep -F "ports='bat0'" "$script" >/dev/null
grep -F '. /lib/functions.sh' "$script" >/dev/null
! grep -F "eth0" "$script" >/dev/null
sh -n "$script"
sh -n "$repo/package/openmanet-batman-fix/files/etc/init.d/openmanet-batman"

echo 'PASS: OpenMANET BATMAN-V source checks'
