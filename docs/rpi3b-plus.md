# Raspberry Pi 3B+ image

Version 1 includes a native 64-bit Raspberry Pi 3B+ image built from the
`bcm2710` target. It includes the Morse MM8108 USB HaLow driver and firmware,
the OpenMANET mesh wizard, BATMAN-adv, OpenMANETd, and the IWFCam RTSP bridge.

Build profile:

```text
boards/ekh-bcm2710/target_diffconfig
```

Images are emitted under:

```text
bin/targets/bcm27xx/bcm2710/
```

Flash the `*-rpi-3-squashfs-factory.img.gz` image for a fresh installation.
Use the matching `*-rpi-3-squashfs-sysupgrade.img.gz` only when upgrading an
existing OpenWrt installation. Set the root password on first boot and run
the 802.11s Mesh wizard before expecting the HaLow/BATMAN network to pass
traffic.

The IWFCam service is disabled only when `iwfcam.main.enabled` is set to `0`.
Otherwise it starts at boot, waits for `iwfcam.main.camera_mac`, and then
serves `rtsp://<node-ip>:8554/cam`. See [IWFCAM.md](IWFCAM.md).

This release was compiled and inspected on the build server. Physical Pi 3B+
boot and radio testing must be performed on the target hardware.
