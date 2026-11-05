# SD-card expansion guide moved

The complete, beginner-friendly instructions are now in
[docs/SD_CARD_RESIZE.md](SD_CARD_RESIZE.md).

That guide covers macOS with a Linux VM, the Linux procedure, native Linux,
`resizepart 2 100%`,
dynamic SquashFS `bytes_used` detection, loop-device F2FS verification with
`blkid`, `fsck.f2fs -f`, `resize.f2fs`, first-boot overlay initialization, and
safe ejection. This release does **not** resize partitions or filesystems
during boot.
