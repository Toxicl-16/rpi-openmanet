# OpenMANET Raspberry Pi Safe Firmware

This repository contains the corrected public OpenMANET firmware source based
on the known-working v0.5.2 baseline. Version 1 publishes matching images for
the Raspberry Pi 5 (`bcm2712`) and Raspberry Pi 3B+ (`bcm2710`), both with
Morse Micro MM8108 USB HaLow support.

## Current release

Download the pre-built firmware from
[v1.0.0](https://github.com/Toxicl-16/rpi-openmanet/releases/tag/v1.0.0).
The release contains factory and sysupgrade images for both boards, manifests,
checksums, release notes, and the SD-card expansion guide.

The published firmware uses SquashFS with an F2FS writable overlay. It does
not resize the SD card during boot. Follow the beginner-friendly [SD-card
resize guide](docs/SD_CARD_RESIZE.md)
from native Linux or a Kali/Ubuntu Linux VM on macOS when more card space is
needed.

## What this release fixes

- BATMAN-V creates `bat0`, binds each enabled 802.11s interface as a BATMAN
  hard interface, and adds only `bat0` to the HaLow-side bridge.
- Docker uses the F2FS-compatible `vfs` storage driver and includes the
  capability packages needed to avoid
  `lsetxattr security.capability: operation not supported`.
- The main OpenMANET portal uses dark surfaces instead of unintended white
  cards and backgrounds.
- The Pi 3B+ image includes an IWFCam H.264-to-RTSP bridge that waits for the
  configured camera MAC before starting at boot.
- GoLangTAKServer no longer conflicts with OpenMANETd: plain TAK TCP uses
  port 8092, while OpenMANETd retains its API on port 8087.
- Storage expansion is documented as an offline manual operation; there is no
  automatic or dynamic resize service in the firmware.

## Scope

The stable Pi 5 image includes:

- Morse MM8108 USB driver and firmware, 802.11s mesh support, and the OpenMANET
  mesh wizard
- BATMAN-adv, `batctl`, `openmanetd`, and the OpenMANET Dark LuCI theme
- Native ARM64 GoLangTAKServer for TAK clients
- Raspberry Pi 5 onboard Wi-Fi support

The main OpenMANET portal is served by OpenMANETd on port 8080 (HTTP) and
8081 (HTTPS). Its API uses port 8087. GoLangTAKServer uses secure TAK TCP on
8089, plain TAK TCP on 8092, its dashboard on 8443, and enrollment on 8446.

## TAK service

The firmware includes a native ARM64
[GolangTAKServer](https://github.com/grangedevgroup-code/TAK-Backend) service.
See the [native TAK guide](docs/EXPERIMENTAL_NATIVE_TAK.md) for setup and
client connection details.

The Pi 3B+ image includes the OpenMANET manager, mesh wizard, BATMAN-adv,
Morse MM8108 support, and the automatic IWFCam RTSP service. The Pi 5 image
includes native GoLangTAKServer; it does not include Docker or OpenTAKServer.

## Flash and first boot

1. Choose the factory image matching your board (`rpi-3` for Pi 3B+, `rpi-5`
   for Pi 5) and flash it with Raspberry Pi Imager or an equivalent raw-image
   tool.
2. Connect directly to the board's Ethernet port.
3. Open LuCI at [http://10.41.254.1](http://10.41.254.1), the OpenMANET portal
   at [http://10.41.254.1:8080](http://10.41.254.1:8080), or SSH to
   `root@10.41.254.1`.
4. Set a root password immediately, then open **Wizards**, choose
   **802.11s Mesh**, and select the Mesh Point or Mesh Gate role.

The first-boot network is `10.41.254.0/24`; it intentionally does not use
`192.168.1.1`.

See [docs/rpi5.md](docs/rpi5.md) and [docs/rpi3b-plus.md](docs/rpi3b-plus.md)
for board-specific setup and validation details. For the camera service, see
[docs/IWFCAM.md](docs/IWFCAM.md).

## Build from source

Use a supported Linux build host with the normal OpenWrt build dependencies.
From the repository root:

```sh
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/apply-build-fixes.sh
./scripts/morse_setup.sh -b ekh-bcm2712
CONFIG_ALFRED_GPSD=n make -j"$(nproc)" V=s

# For the Pi 3B+ image:
./scripts/morse_setup.sh -b ekh-bcm2710
CONFIG_ALFRED_GPSD=n make -j"$(nproc)" V=s
```

`CONFIG_ALFRED_GPSD=n` disables an optional Alfred GPS sub-build that the
current pinned OpenMANET feed does not pass through correctly. It matches the
Pi 5 profile, which does not select the GPS service.

Pi 5 images are written to `bin/targets/bcm27xx/bcm2712/`; Pi 3B+ images are
written to `bin/targets/bcm27xx/bcm2710/`.

Run the repository checks with:

```sh
git diff --check
for test in scripts/tests/test-*.sh; do "$test"; done
```

The release notes distinguish compilation and image inspection from physical
hardware testing. A successful build does not by itself prove boot or radio
operation.

## Upstream sources and licensing

The tree retains the upstream OpenWrt, Morse Micro, OpenMANET, and other
component licenses and attribution. Feed revisions are pinned in
[`feeds.conf.default`](feeds.conf.default); the Pi 5 board profile is defined
in [`boards/ekh-bcm2712/target_diffconfig`](boards/ekh-bcm2712/target_diffconfig).

## Sources and attribution

This release is a derivative build assembled from the following projects:

- [Build with Parallel Pi 5 Morse/OpenWrt firmware](https://github.com/buildwithparallel/openwrt-morse-rpi5)
  — the Pi 5/Morse firmware foundation and hardware backport work
- [OpenMANET firmware](https://github.com/OpenMANET/firmware) — OpenMANET's
  OpenWrt firmware project and integration model
- [OpenMANET packages](https://github.com/OpenMANET/packages) — the pinned
  OpenMANET package feed, including the portal and configuration components
- [openmanetd](https://github.com/OpenMANET/openmanetd) — the OpenMANET manager
  daemon and Alfred integration
- [OpenTAKServer](https://github.com/brian7704/OpenTAKServer) — the TAK server
  deployed by the included Docker Compose service
- [GolangTAKServer](https://github.com/grangedevgroup-code/TAK-Backend) — the
  native ARM64 TAK alternative used by the experimental branch
- [Morse Micro OpenWrt](https://github.com/MorseMicro/openwrt) and the
  [Morse Micro feed](https://github.com/MorseMicro/morse-feed) — the base SDK,
  HaLow driver integration, and radio firmware packages
- [OpenWrt](https://github.com/openwrt/openwrt) — the Pi 5 bcm2712/RP1 and
  Linux 6.6 hardware sources backported into this tree
- [OpenWrt packages](https://github.com/openwrt/packages),
  [routing](https://github.com/openwrt/routing), and
  [LuCI](https://github.com/openwrt/luci) — supporting package feeds pinned in
  [`feeds.conf.default`](feeds.conf.default)
- [iwfcam-rtsp](https://github.com/Bedz01/iwfcam-rtsp) — the upstream
  IWFCam UDP protocol and RTSP bridge source, adapted here for the field
  camera's H.264 Annex-B stream
- [IWFCam](https://github.com/fersatgit/IWFCam) — the original public
  reverse-engineering reference for the camera protocol

Please consult each upstream project for its license and attribution terms.
Those licenses and notices remain part of this source tree and its generated
firmware packages.
