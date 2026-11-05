#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
upstream_ref=golangtakserver-v1.6.3
output=${1:-$repo_root/firmware-output/golangtakserver-linux-arm64-openmanet-ui1}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

git clone --depth 1 --branch "$upstream_ref" \
	'https://github.com/grangedevgroup-code/TAK-Backend.git' "$work/TAK-Backend"
git -C "$work/TAK-Backend" apply \
	"$repo_root/package/golangtakserver/patches/100-qr-layout.patch"

mkdir -p "$(dirname "$output")"
TARGETS=linux/arm64 OUT="$work/dist" \
	"$work/TAK-Backend/GolangTAKServer/scripts/build.sh" 1.6.3-openmanet-ui1
install -m 0755 "$work/dist/golangtakserver-linux-arm64" "$output"
sha256sum "$output"
