# OpenMANET firmware v1.0.0

Version 1 is the first dual-board release of this corrected public firmware
tree. It is built from the public OpenMANET v0.5.2 baseline and preserves the
working Pi 3B+ and Pi 5 paths while packaging the tested IWFCam service for the
Pi 3B+ image.

## Release assets

- `pi3/openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2710-rpi-3-squashfs-factory.img.gz` — 37,605,445 bytes
- `pi3/openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2710-rpi-3-squashfs-sysupgrade.img.gz` — 37,606,427 bytes
- `pi5/openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz` — 36,288,444 bytes
- `pi5/openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2712-rpi-5-squashfs-sysupgrade.img.gz` — 36,289,290 bytes
- Per-board manifests
- `SHA256SUMS`
- This release note and the manual SD-card expansion guide

The image SHA-256 values are:

| Board/image | SHA-256 |
| --- | --- |
| Pi 3B+ factory | `34bfa2f2cdb0fae69d534f2a5672d1fb24add9216931073557b9a400ebc42271` |
| Pi 3B+ sysupgrade | `6ccb45fd682744a5307279c7e6174713f035a86ebd33a06f7f1ae4023d4c6ac6` |
| Pi 5 factory | `6a35831ba7960ca7c85ca7502d402cfd22c051a013be70808f59be05436d4e0e` |
| Pi 5 sysupgrade | `8a82585847daa01f8d5c00087edf41f672facfee079154ee0018b38779afdb2f` |

Use a factory image for a freshly flashed SD card. Use sysupgrade only for an
existing compatible installation. The images do not resize partitions or
filesystems automatically.

## Included fixes and features

- BATMAN-V `bat0` creation, hard-interface binding, and bridge membership.
- Ethernet remains an independent DHCP uplink when the Pi 5 is used as a
  gateway.
- Docker uses F2FS-compatible `vfs` storage and capability support.
- The main OpenMANET portal uses the maintained OpenMANET Dark theme. Port 8080
  was not modified by this theme work.
- Native GoLangTAKServer is included in the Pi 5 image; OpenTAKServer and its
  Docker deployment are not included in this version.
- The Pi 3B+ image includes the IWFCam H.264-to-RTSP bridge. Its procd service
  waits for the configured camera MAC before starting at boot and requires no
  camera Internet access.

## Validation

The build server ran the source checks, built both target profiles, inspected
both manifests, and generated SHA-256 checksums. No Raspberry Pi hardware was
booted by the build process; hardware boot, radio, Docker, TAK-client, and
RTSP/EUD acceptance testing remain separate field tests.
