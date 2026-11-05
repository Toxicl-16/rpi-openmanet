#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
board="$repo/boards/ekh-bcm2712/target_diffconfig"
script="$repo/package/openmanet-batman-fix/files/usr/sbin/openmanet-batman"

grep -F 'CONFIG_PACKAGE_openmanet-batman-fix=y' "$board" >/dev/null
grep -F 'uci_set_option network bat0 routing_algo BATMAN_V' "$script" >/dev/null
grep -F 'uci_set_option network "$hardif" proto batadv_hardif' "$script" >/dev/null
grep -F 'uci_set_option network "$hardif" master bat0' "$script" >/dev/null
grep -F 'uci_add_list_if_missing network "$section" ports bat0' "$script" >/dev/null
grep -F 'uci_delete_option network bat0 disabled' "$script" >/dev/null
grep -F 'mesh_nolearn 1' "$script" >/dev/null
grep -F 'network wan device eth0' "$script" >/dev/null
grep -F '. /lib/functions.sh' "$script" >/dev/null
grep -F 'procd_add_reload_trigger network wireless mesh11sd' "$repo/package/openmanet-batman-fix/files/etc/init.d/openmanet-batman" >/dev/null
grep -F 'repair reload' "$repo/package/openmanet-batman-fix/files/etc/init.d/openmanet-batman" >/dev/null
grep -F 'START=99' "$repo/package/openmanet-batman-fix/files/etc/init.d/openmanet-batman" >/dev/null
grep -F 'ahwlan|bat0|batmesh*)' "$repo/package/openmanet-batman-fix/files/etc/hotplug.d/iface/99-openmanet-batman" >/dev/null
grep -F 'openmanet-batman repair reload' "$repo/package/openmanet-batman-fix/files/etc/hotplug.d/iface/99-openmanet-batman" >/dev/null
sh -n "$script"
sh -n "$repo/package/openmanet-batman-fix/files/etc/init.d/openmanet-batman"
sh -n "$repo/package/openmanet-batman-fix/files/etc/hotplug.d/iface/99-openmanet-batman"

echo 'PASS: OpenMANET BATMAN-V source checks'
