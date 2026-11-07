# OpenMANET firmware v1.0.1

This release rebuilds the corrected OpenMANET firmware for both supported
boards from the public v0.5.2 baseline. It includes the reviewed OpenMANET
package-feed fork pinned in `feeds.conf.default`.

## Firmware images

Use a factory image for a freshly flashed SD card. Use a sysupgrade image only
for an existing compatible installation. The firmware does not resize the SD
card or F2FS overlay automatically during boot.

| Board | Image | Size | SHA-256 |
| --- | --- | ---: | --- |
| Raspberry Pi 3B+ | `openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2710-rpi-3-squashfs-factory.img.gz` | 37,175,353 bytes | `367b55b1e9b0eea20de90a17cbac763ead961ac0cff2622007ea35616ed12fea` |
| Raspberry Pi 3B+ | `openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2710-rpi-3-squashfs-sysupgrade.img.gz` | 37,176,335 bytes | `10279659f185ffdf9d8463c45bc89d70403a81b5f70187bf798e5149a344e52f` |
| Raspberry Pi 5 | `openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz` | 36,288,859 bytes | `2962e98c504c35615ef21ac87c8d6052234f26e60884bd0ab9a52a2cb52e75aa` |
| Raspberry Pi 5 | `openwrt-23.05.5-morse-2.9-dev-bcm27xx-bcm2712-rpi-5-squashfs-sysupgrade.img.gz` | 36,289,705 bytes | `8a0c414ef9a69006ecbf603af93d9be7be75d72a862d85665741ff2cf321b44c` |

The release also includes per-board manifests, `SHA256SUMS`, this note, and
the manual [SD-card expansion guide](docs/SD_CARD_RESIZE.md).

## Included changes

- BATMAN-V `bat0` creation, hard-interface binding, bridge membership, and
  topology fallback behavior.
- Alfred startup/socket initialization for mesh topology reporting.
- Ethernet remains an independent DHCP uplink when the Pi 5 is used as a
  gateway.
- Docker uses the corrected F2FS-compatible storage/capability configuration.
- The main OpenMANET portal uses the maintained OpenMANET Dark theme. Port 8080
  was not modified by the theme work.
- Native GoLangTAKServer is included in the Pi 5 image; its voice service is
  disabled by default. OpenTAKServer and its Docker deployment are not included
  in this release.
- The Pi 3B+ image includes the IWFCam H.264-to-RTSP bridge and boot service.

## Validation

The build server completed both target builds with exit code 0. The generated
manifests contain `kmod-batman-adv`, `batctl-full`,
`luci-proto-batman-adv`, `alfred`, `openmanetd`, and the OpenMANET Dark theme;
the Pi 5 manifest also contains GoLangTAKServer, and the Pi 3B+ manifest
contains `iwfcam-rtsp`. The built theme package contains `header.htm`,
`dark.css`, and `openmanet-dark.css`.

The source validation tests passed, including BATMAN, Docker, theme, IWFCam,
and SD-card documentation checks. No automatic filesystem-resize boot logic
was introduced. Hardware boot, radio, Docker runtime, TAK-client, and RTSP/EUD
acceptance testing must still be performed on the physical Raspberry Pis.
