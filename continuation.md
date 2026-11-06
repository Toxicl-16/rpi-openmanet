# Repository handoff

This repository now has one active release branch, `release-v1.0.0`, and two documented Raspberry Pi targets:

- Pi 5 (`bcm2712`): Build with Parallel-based build with MM8108 USB, `openmanetd`, BATMAN-V repair, OpenMANET Dark, and native GoLangTAKServer.
- Pi 3B+ (`bcm2710`): OpenMANET image with MM8108 USB, OpenMANETd, BATMAN-adv, and the automatic IWFCam RTSP service.

Version 1 publishes both factory and sysupgrade images. Build outputs, feeds,
downloads, staging directories, and logs are intentionally untracked; release
assets are uploaded to GitHub rather than committed to the source tree.

Do not use boot emulation as an acceptance criterion. The available QEMU release does not emulate a Raspberry Pi 5 machine; final boot and MM8108 radio validation require physical hardware.
