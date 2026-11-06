# Raspberry Pi 5 image

Version 1 includes a Raspberry Pi 5 (`bcm2712`) image for the Morse MM8108
USB HaLow module. It also includes the Pi 5 onboard Wi-Fi support, OpenMANET
portal, BATMAN-V repair service, and native GoLangTAKServer.

The profile is [`boards/ekh-bcm2712/target_diffconfig`](../boards/ekh-bcm2712/target_diffconfig).
The image uses a 64 MiB FAT boot partition and a 4 GiB SquashFS/F2FS root
layout. The firmware never resizes partitions or filesystems during boot.

## Important fixes

- BATMAN-V creates `bat0`, binds the enabled 802.11s interface through a
  `batadv_hardif`, and bridges only `bat0` into the HaLow-side bridge.
- Docker uses the F2FS-compatible `vfs` storage driver and includes the
  capability packages needed to avoid `lsetxattr security.capability:
  operation not supported`.
- The main OpenMANET portal has the OpenMANET Dark theme. Port 8080 was not
  modified by the theme work.
- GoLangTAKServer runs natively under procd; it does not require Docker or
  OpenTAKServer.

## First boot

Flash the `*-rpi-5-squashfs-factory.img.gz` asset, connect directly to
Ethernet, open LuCI at `http://10.41.254.1`, set the root password, and run
**Wizards → 802.11s Mesh**. Select Mesh Gate or Mesh Point as appropriate.

Verify the BATMAN chain after setup:

```sh
ip link show bat0
batctl meshif bat0 if
uci show network.bat0 network.batmesh
bridge link show master br-ahwlan
```

The physical HaLow interface should be a BATMAN hard interface, not a direct
member of `br-ahwlan`; `bat0` should be the bridge member. Ethernet remains an
independent uplink when configured as the gateway.

## Native TAK

GoLangTAKServer is managed by `/etc/init.d/golangtakserver`. Its setup and
client ports are documented in [EXPERIMENTAL_NATIVE_TAK.md](EXPERIMENTAL_NATIVE_TAK.md).

## Build and validation

```sh
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/apply-build-fixes.sh
./scripts/morse_setup.sh -b ekh-bcm2712
CONFIG_ALFRED_GPSD=n make -j"$(nproc)" V=s
```

Run `git diff --check` and every `scripts/tests/test-*.sh` script. This
validates source and image generation; it does not replace physical boot,
radio, Docker, or TAK-client testing.
