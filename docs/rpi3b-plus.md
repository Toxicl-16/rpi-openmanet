# Raspberry Pi 3B+ compatibility note

The Raspberry Pi 3B+ source target is retained to preserve the previously
working OpenMANET build. This repository's `v0.5.3-rpi5-safe` release is a Pi 5
release; it does not publish or replace a Pi 3B+ image.

The Pi 3B+ board configuration is kept under
[`boards/ekh-bcm2711`](../boards/ekh-bcm2711/). The Pi 5-only BATMAN repair
package and F2FS/Docker options are not selected by that profile.

To regenerate the Pi 3B+ configuration for a source-level compatibility check:

```sh
./scripts/morse_setup.sh -b ekh-bcm2711
```

This confirms the board profile remains selectable. A new Pi 3B+ image and
physical Pi 3B+ boot test were outside the scope of the safe Pi 5 release.
