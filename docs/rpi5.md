# Raspberry Pi 5 safe-release guide

This is the active target for the `v0.5.2-rpi5-safe` release. It is built from
the public v0.5.2 baseline with the focused fixes described below.

## Hardware scope

- Raspberry Pi 5 (`bcm2712`), including Pi 500 where compatible
- Morse Micro MM8108 USB HaLow module
- Raspberry Pi 5 onboard BCM43455 Wi-Fi

The MM6108 SPI path is not part of this release's verified hardware scope. No
physical Pi 5 was available for boot or RF acceptance testing, so the release
status is based on source validation and successful image compilation.

## Image profile

The profile is [`boards/ekh-bcm2712/target_diffconfig`](../boards/ekh-bcm2712/target_diffconfig).
It selects the Pi 5 6.6 kernel target, Morse HaLow support, the OpenMANET mesh
wizard, BATMAN-adv, Docker, OpenTAKServer, and the OpenMANET Argon theme.

The image uses a 64 MiB FAT boot partition and a 4 GiB SquashFS/root partition.
The writable F2FS overlay and Docker data live in the root partition. The
firmware never resizes partitions or filesystems during boot.

## Fixes in this release

### BATMAN-V topology

At boot, the Pi 5 profile discovers enabled 802.11s wireless interfaces and
configures each as a `batadv_hardif` attached to `bat0` using `BATMAN_V`. The
HaLow-side bridge receives `bat0`; the physical mesh interface is not bridged
directly, and the Ethernet uplink is not moved into that bridge.

The repair service is installed as:

```text
/etc/init.d/openmanet-batman
/usr/sbin/openmanet-batman
```

The OpenMANET mesh wizard remains the source of the mesh role and wireless
settings.

### Docker on the F2FS overlay

The profile enables F2FS security xattrs, includes `libcap` and `libcap-bin`,
and configures Docker with:

```text
storage driver: vfs
data root: /opt/docker/
```

This avoids the `lsetxattr security.capability: operation not supported` error
from extracting Docker layers through `overlay2` on this storage layout.

On a booted device, check the result with:

```sh
docker info --format '{{.Driver}} {{.DockerRootDir}}'
getcap /usr/bin/ping
cp /bin/true /tmp/openmanet-capability-test
setcap cap_net_raw+ep /tmp/openmanet-capability-test
getcap /tmp/openmanet-capability-test
rm -f /tmp/openmanet-capability-test
```

### Portal theme

The main OpenMANET portal cards, detail panels, device box, and graph nodes use
dark surfaces and readable borders. The application on port 8080 was not
modified.

## Flashing and first boot

Flash the `*-factory.img.gz` asset from the
[release page](https://github.com/Toxicl-16/rpi-openmanet/releases/tag/v0.5.2-rpi5-safe)
to the SD card. Connect directly to Ethernet and use:

```text
LuCI: http://10.41.254.1
SSH:  root@10.41.254.1
```

Set a root password, then open **Wizards → 802.11s Mesh** and select Mesh Gate
or Mesh Point. OpenTAKServer starts after Docker and pulls its ARM64 images on
first deployment. Its web UI uses port 8090; port 8080 is outside this release's
changes.

## Manual SD-card expansion

Do not resize the card while the Pi is running. Follow
[SD_CARD_RESIZE.md](SD_CARD_RESIZE.md) from native Linux or a Kali/Ubuntu Linux
VM on macOS. The procedure backs up the full card, preserves partition 2's
start, calculates the SquashFS boundary with `unsquashfs -s`, and grows the
F2FS overlay offline.

## Rebuild and validate

From the repository root after installing the pinned feeds:

```sh
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/apply-build-fixes.sh
./scripts/morse_setup.sh -b ekh-bcm2712
CONFIG_ALFRED_GPSD=n make -j"$(nproc)" V=s
```

Run the source checks with:

```sh
git diff --check
for test in scripts/tests/test-*.sh; do "$test"; done
```

The published image compiled successfully and includes the BATMAN-adv module,
`batctl`, Docker, `libcap`, `libcap-bin`, and `openmanet-batman-fix`. Hardware
boot and runtime behavior remain unverified in this environment.
