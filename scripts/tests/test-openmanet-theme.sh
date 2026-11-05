#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
patch="$repo/patches/build-fixes/015-openmanet-dark-theme.patch"

grep -F 'luci-theme-openmanetargon' "$patch" >/dev/null
grep -F 'LUCI_TITLE:=LuCI OpenMANET Dark Theme' "$patch" >/dev/null
grep -F -- '--home-surface: #2d2d2d' "$patch" >/dev/null
grep -F -- '--background-color-high: #252526' "$patch" >/dev/null
grep -F '.cards .card' "$patch" >/dev/null
grep -F '.dropdown-menu' "$patch" >/dev/null
grep -F '015-openmanet-dark-theme.patch' "$repo/scripts/apply-build-fixes.sh" >/dev/null

# The theme patch is scoped to the LuCI OpenMANET theme; it must not touch
# OpenTAKServer or any port-8080 application.
! grep -F 'luci-mod-home' "$patch" >/dev/null
! grep -F '8080' "$patch" >/dev/null

echo 'PASS: OpenMANET portal theme source checks'
