#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
patch="$repo/patches/build-fixes/013-openmanet-home-dark-theme.patch"

grep -F 'feeds/openmanet/luci/luci-mod-home' "$patch" >/dev/null
grep -F -- '--home-surface: #2d2d2d' "$patch" >/dev/null
grep -F 'background-color: var(--home-surface-raised)' "$patch" >/dev/null
grep -F 'background: var(--home-surface-raised)' "$patch" >/dev/null
grep -F 'background: var(--home-surface)' "$patch" >/dev/null
grep -F '013-openmanet-home-dark-theme.patch' "$repo/scripts/apply-build-fixes.sh" >/dev/null

# The portal patch is scoped to luci-mod-home; it must not touch OpenTAKServer
# or any port-8080 application.
! grep -F '8080' "$patch" >/dev/null

echo 'PASS: OpenMANET portal theme source checks'
