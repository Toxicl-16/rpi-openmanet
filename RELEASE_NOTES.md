# OpenMANET Raspberry Pi 5 Safe Release

This release is built from the public OpenMANET v0.5.2 baseline at commit
`536b3f8078c9074df383b19e746103404d5296d2`.

## Included fixes

- Correct BATMAN-V `bat0` creation, mesh hard-interface binding, and bridge
  membership for the Pi 5 OpenMANET mesh wizard.
- Enable F2FS security xattrs and configure Docker's `vfs` storage driver to
  avoid `lsetxattr security.capability: operation not supported` during layer
  extraction.
- Replace unintended white surfaces in the main OpenMANET portal theme. The
  application on port 8080 is unchanged.
- Document offline, manual SquashFS/F2FS overlay expansion from Linux or a
  Linux VM on macOS. The firmware does not resize storage during boot.

## Build and validation

- Pi 5 factory image SHA-256:
  `d007884ee2514ab0c5cb597c8c147eacb94e0b6714b777722312b610e3320bbb`
- Pi 5 sysupgrade image SHA-256:
  `2bf7ecf30005d1137429bc5c843bdc876d61cc8a4ef8ffc1934f7df2a24468d9`
- All repository source validation tests pass.
- The complete Pi 5 image build succeeds, including the BATMAN-adv module,
  `batctl`, Docker, `libcap`, `libcap-bin`, and the BATMAN repair service.
- The Pi 3 profile configuration check succeeds and does not select the Pi 5
  BATMAN repair package or Pi 5 F2FS options.
- Hardware boot and runtime validation has not been performed; a Raspberry Pi
  test device was not available in this build environment.

