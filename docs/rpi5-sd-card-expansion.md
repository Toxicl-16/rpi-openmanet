# Raspberry Pi 5 SD-card expansion (manual)

The Pi 5 image uses a 64 MiB FAT boot partition followed by a SquashFS root
partition. The writable F2FS overlay is stored after the SquashFS bytes inside
that same root partition. A factory image therefore exposes only the image's
root-partition size until the partition and F2FS filesystem are expanded.

This release deliberately does **not** resize partitions or filesystems during
boot. Perform this procedure offline from another Linux system, or from a
Linux virtual machine with the SD card passed through as a block device.

## Safety rules

- Back up the complete SD card before changing its partition table.
- Verify the whole-card device twice; the commands below can destroy the
  selected device if it is wrong.
- Power off the Pi and unmount every partition on the target card. Never resize
  the active root or overlay filesystem.
- Preserve partition 2's starting sector. Only its end may move.
- Do not format partition 2 and do not hardcode the overlay offset. It depends
  on the SquashFS image's actual `bytes_used` value.
- If `blkid` does not report F2FS, stop rather than guessing. A fresh image may
  have an unformatted rootfs-data area; let normal first boot create it, or
  obtain help before formatting any data-bearing device.

## macOS with a Linux VM

1. Identify the card on macOS with `diskutil list`. Record the whole-disk
   identifier, such as `/dev/disk4`, not `/dev/disk4s2`.
2. Back it up before passing the card to the VM:

   ```sh
   diskutil unmountDisk /dev/disk4
   sudo dd if=/dev/rdisk4 of="$HOME/openmanet-rpi5-before-resize.img" bs=4m
   sync
   ```

3. Pass the physical SD reader/card through to the Linux VM. In the VM, run
   `lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS` and identify its Linux device,
   such as `/dev/sdb`. The VM name is not necessarily `disk4`.
4. Run the [Linux procedure](#linux-procedure) in the VM. Do not mount the
   card's root partition in the VM's file browser.
5. Shut down the VM or detach the card cleanly, then reinsert it in the Pi.

If physical passthrough is unavailable, attach the complete backup image to
the VM, resize the image there, and write it back only after checking the image
device. To restore an image on macOS:

```sh
diskutil unmountDisk /dev/disk4
sudo dd if="$HOME/openmanet-rpi5-after-resize.img" of=/dev/rdisk4 bs=4m
sync
diskutil eject /dev/disk4
```

## Linux procedure

Boot Linux from a different disk. Insert the powered-off card and identify the
whole device:

```sh
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
```

Set `DISK` to the whole card, not a partition. `/dev/sdX` is only a placeholder:

```sh
DISK=/dev/sdX
sudo umount "${DISK}1" "${DISK}2" 2>/dev/null || true
sudo parted -s "$DISK" unit s print
case "$DISK" in
  *mmcblk*|*nvme*) PART="${DISK}p2" ;;
  *)              PART="${DISK}2"  ;;
esac
sudo blockdev --getsize64 "$PART"
sudo blkid "$PART"
```

Record partition 2's start sector. Grow only its end, then confirm its start
is unchanged. Substitute the partition number if the image was repartitioned:

```sh
sudo parted -s "$DISK" unit s resizepart 2 100%
sudo partprobe "$DISK" || true
sudo udevadm settle
sudo parted -s "$DISK" unit s print
```

Calculate the overlay offset from the SquashFS superblock. SquashFS stores its
little-endian `bytes_used` field at byte 40; this layout aligns the following
rootfs-data area to 64 KiB. Do not substitute a remembered offset:

```sh
SQUASH_BYTES=$(sudo dd if="$PART" bs=1 skip=40 count=8 status=none \
  | od -An -tu8 | tr -d '[:space:]')
case "$SQUASH_BYTES" in
  ''|*[!0-9]*) echo "Could not read SquashFS bytes_used" >&2; exit 1 ;;
esac
OFFSET=$(( (SQUASH_BYTES + 65535) / 65536 * 65536 ))
PART_BYTES=$(sudo blockdev --getsize64 "$PART")
[ "$OFFSET" -lt "$PART_BYTES" ] || exit 1
printf 'SquashFS bytes_used=%s, overlay offset=%s, partition bytes=%s\n' \
  "$SQUASH_BYTES" "$OFFSET" "$PART_BYTES"
```

Create a temporary loop device for the bytes after SquashFS. It must be
unmounted and identified as F2FS before changing it:

```sh
LOOP=$(sudo losetup --find --show --offset "$OFFSET" \
  --sizelimit "$((PART_BYTES - OFFSET))" "$PART")
trap 'sudo losetup -d "$LOOP" 2>/dev/null || true' EXIT
if sudo findmnt --source "$LOOP" >/dev/null 2>&1; then
  echo "$LOOP is mounted; aborting" >&2; exit 1
fi
sudo blkid "$LOOP"
test "$(sudo blkid -o value -s TYPE "$LOOP")" = f2fs || {
  echo "Overlay is not identified as F2FS; aborting" >&2; exit 1
}
```

Repair recoverable metadata, then resize offline to the new loop-device size:

```sh
sudo fsck.f2fs -f "$LOOP"
sudo resize.f2fs "$LOOP"
sudo blockdev --getsize64 "$PART"   # partition size
sudo blockdev --getsize64 "$LOOP"   # F2FS backing size
sudo fsck.f2fs -l "$LOOP" | sed -n '1,80p'
sudo losetup -d "$LOOP"
sync
```

After boot, verify the mounted overlay and persistence:

```sh
df -h /overlay
mount | grep ' /overlay '
touch /overlay/rpi5-resize-test
reboot
test -f /overlay/rpi5-resize-test && echo 'overlay data persisted'
```

If the Pi does not boot, power it off and restore the complete backup to the
same card. On Linux:

```sh
sudo dd if="$HOME/openmanet-rpi5-before-resize.img" of="$DISK" \
  bs=4M status=progress conv=fsync
sync
```
