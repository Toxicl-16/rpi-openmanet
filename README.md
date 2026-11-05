# OpenMANET Raspberry Pi Safe Firmware

This repository contains the corrected public OpenMANET firmware source based
on the known-working v0.5.2 baseline. The active release target is the
Raspberry Pi 5 (`bcm2712`) with a Morse Micro MM8108 USB HaLow radio.

## Current release

Download the pre-built images and packages from
[v0.5.4-rpi5-safe](https://github.com/Toxicl-16/rpi-openmanet/releases/tag/v0.5.4-rpi5-safe).
The release includes factory and sysupgrade images, checksums, the image
manifest, build metadata, and all generated OpenWrt packages.

The published firmware is a Pi 5 SquashFS/F2FS image. It does not resize the
SD card during boot. Follow the beginner-friendly [SD-card resize guide](docs/SD_CARD_RESIZE.md)
from native Linux or a Kali/Ubuntu Linux VM on macOS when more card space is
needed.

## What this release fixes

- BATMAN-V creates `bat0`, binds each enabled 802.11s interface as a BATMAN
  hard interface, and adds only `bat0` to the HaLow-side bridge.
- Docker uses the F2FS-compatible `vfs` storage driver and includes the
  capability packages needed to avoid
  `lsetxattr security.capability: operation not supported`.
- The main OpenMANET portal uses dark surfaces instead of unintended white
  cards and backgrounds. The application on port 8080 is unchanged.
- Storage expansion is documented as an offline manual operation; there is no
  automatic or dynamic resize service in the firmware.

## Scope

The stable Pi 5 image includes:

- Morse MM8108 USB driver and firmware, 802.11s mesh support, and the OpenMANET
  mesh wizard
- BATMAN-adv, `batctl`, `openmanetd`, and the OpenMANET Dark LuCI theme
- Docker, Compose, containerd, runc, and the OpenTAKServer deployment package
- Raspberry Pi 5 onboard Wi-Fi support

OpenTAKServer container images are pulled on first start, so initial deployment
requires Internet access unless an offline image bundle is supplied. Its web
UI is served on port 8090; this firmware does not modify the separate port 8080
application.

## Experimental native TAK branch

The [`experimental-native-tak`](https://github.com/Toxicl-16/rpi-openmanet/tree/experimental-native-tak)
branch replaces OpenTAKServer and Docker with a native ARM64
[GolangTAKServer](https://github.com/grangedevgroup-code/TAK-Backend) service.
It is intended for Pi 5 testing only and is not a replacement for the stable
release until ATAK/iTAK connectivity has been verified on hardware. See the
[experimental native TAK guide](docs/EXPERIMENTAL_NATIVE_TAK.md).

The Raspberry Pi 3B+ target remains in the source tree as a compatibility
reference. This release publishes Pi 5 images only and does not replace the
Pi 3B+ configuration.

## Flash and first boot

1. Flash the `*-factory.img.gz` release asset with Raspberry Pi Imager or an
   equivalent raw-image tool.
2. Connect directly to the Pi 5 Ethernet port.
3. Open LuCI at [http://10.41.254.1](http://10.41.254.1), or SSH to
   `root@10.41.254.1`.
4. Set a root password immediately, then open **Wizards**, choose
   **802.11s Mesh**, and select the Mesh Point or Mesh Gate role.

The first-boot network is `10.41.254.0/24`; it intentionally does not use
`192.168.1.1`.

See [docs/rpi5.md](docs/rpi5.md) for the Pi 5 profile, Docker checks, build
instructions, and validation status.

## Build from source

Use a supported Linux build host with the normal OpenWrt build dependencies.
From the repository root:

```sh
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/apply-build-fixes.sh
./scripts/morse_setup.sh -b ekh-bcm2712
CONFIG_ALFRED_GPSD=n make -j"$(nproc)" V=s
```

`CONFIG_ALFRED_GPSD=n` disables an optional Alfred GPS sub-build that the
current pinned OpenMANET feed does not pass through correctly. It matches the
Pi 5 profile, which does not select the GPS service.

Images are written to:

```text
bin/targets/bcm27xx/bcm2712/
```

Run the repository checks with:

```sh
git diff --check
for test in scripts/tests/test-*.sh; do "$test"; done
```

The released build compiled successfully and passed all source checks. Physical
Pi 5 boot and runtime testing were not available in the release build
environment.

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

Please consult each upstream project for its license and attribution terms.
Those licenses and notices remain part of this source tree and its generated
firmware packages.
