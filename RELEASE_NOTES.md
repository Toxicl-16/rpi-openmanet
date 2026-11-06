# OpenMANET firmware v1.0.0

Version 1 is the first dual-board release of this corrected public firmware
tree. It is built from the public OpenMANET v0.5.2 baseline and preserves the
working Pi 3B+ and Pi 5 paths while packaging the tested IWFCam service for the
Pi 3B+ image.

## Release assets

- Raspberry Pi 3B+ factory image
- Raspberry Pi 3B+ sysupgrade image
- Raspberry Pi 5 factory image
- Raspberry Pi 5 sysupgrade image
- Per-board manifests
- `SHA256SUMS`
- This release note and the manual SD-card expansion guide

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
