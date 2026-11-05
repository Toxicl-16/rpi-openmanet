# Expand an OpenMANET SD card to full capacity

This guide expands a freshly flashed OpenMANET Raspberry Pi image to use the
full SD card. It applies to the Raspberry Pi 5 safe release and similar
OpenMANET images that use a read-only SquashFS root with a writable F2FS
overlay.

The image has two important layers inside partition 2:

1. SquashFS contains the read-only firmware root.
2. F2FS begins after the SquashFS image and supplies writable files such as
   configuration and Docker data.

The F2FS filesystem is exposed through a loop device at an offset within
partition 2. Expanding the card therefore requires both:

- extending partition 2 to the physical card's end; and
- resizing the F2FS filesystem through a loop device at the dynamically
  calculated SquashFS boundary.

The firmware does not perform either operation automatically during boot.

## Important warnings

Read these before running any command:

- Back up the complete SD card first. Partition changes and filesystem repair
  can destroy data if the wrong device is selected.
- Never assume the card is /dev/sdb. Device names change between computers,
  USB readers, and virtual machines.
- Set DISK only after confirming its model and size with lsblk. DISK must be
  the whole card, such as /dev/sdb or /dev/mmcblk0, never a partition.
- Power off the Pi before removing the card. Do not resize a mounted root,
  overlay, partition, or F2FS loop device.
- Preserve partition 2's starting sector. Only its ending sector should move.
- Never run fsck.f2fs or resize.f2fs on the whole partition, because the
  beginning of partition 2 is SquashFS, not F2FS.
- Do not format an unrecognized area as F2FS. If the expected F2FS filesystem
  is not found after first boot, stop and investigate instead of guessing.

## 1. Flash the image

Download the factory image from the
[OpenMANET release page](https://github.com/Toxicl-16/rpi-openmanet/releases/tag/v0.5.3-rpi5-safe)
and verify its checksum using the accompanying rpi5-sha256sums.txt file.

### macOS

1. Insert the card and run:

~~~sh
diskutil list
~~~

Identify the whole card, for example /dev/disk4. Do not use a slice such as
/dev/disk4s2.

2. Unmount and flash it. Replace /dev/disk4 with the device you verified:

~~~sh
diskutil unmountDisk /dev/disk4
gunzip -c openwrt-*-rpi-5-squashfs-factory.img.gz | \
  sudo dd of=/dev/rdisk4 bs=4m status=progress
sync
diskutil eject /dev/disk4
~~~

macOS cannot safely resize the Linux partition and F2FS overlay itself.
Continue with the Linux VM procedure below.

### Native Linux

1. Insert the card and identify it. Run this before and after insertion if
   necessary so the new device is obvious:

~~~sh
lsblk -o NAME,SIZE,MODEL,TYPE,TRAN,MOUNTPOINTS
~~~

2. Set DISK to the verified whole-card device. This is an example only:

~~~sh
DISK=/dev/sdX
~~~

3. Unmount any automatically mounted partitions and flash the image:

~~~sh
part1="$DISK"1
part2="$DISK"2
sudo umount "$part1" "$part2" 2>/dev/null || true
gunzip -c openwrt-*-rpi-5-squashfs-factory.img.gz | \
  sudo dd of="$DISK" bs=4M status=progress conv=fsync
sync
sudo eject "$DISK" 2>/dev/null || true
~~~

Reinsert the card only after the write has finished. For both platforms, make
the complete-card backup in the next section before changing the partition
table.

## 2. macOS: use a Kali or Ubuntu Linux VM

Pass the physical SD reader or the complete card through to the VM. The Linux
device name inside the VM will usually be different from macOS's /dev/diskN.
For example, macOS may call it /dev/disk4 while Kali calls it /dev/sdb.

Inside the VM, run:

~~~sh
lsblk -o NAME,SIZE,MODEL,TYPE,TRAN,MOUNTPOINTS
~~~

Set DISK to the verified Linux whole-card device and then follow the common
Linux procedure below. Do not allow the VM desktop or file manager to mount the
card while partition or filesystem work is in progress.

When finished, unmount and eject it in Linux, shut down or detach the device
from the VM, and eject it on macOS:

~~~sh
diskutil eject /dev/disk4
~~~

Replace /dev/disk4 with the macOS device identified by diskutil list.

## 3. Back up the complete card

Do this from the Linux system that has the card attached. Confirm DISK again
with lsblk before proceeding:

~~~sh
lsblk -o NAME,SIZE,MODEL,TYPE,TRAN,MOUNTPOINTS
DISK=/dev/sdX                 # replace after verification
part1="$DISK"1
part2="$DISK"2
sudo umount "$part1" "$part2" 2>/dev/null || true
sudo dd if="$DISK" of="$HOME/openmanet-sdcard-before-resize.img" \
  bs=4M status=progress conv=fsync
sync
~~~

Keep this backup until the card has booted and the expanded overlay has been
verified. To restore it on Linux later:

~~~sh
sudo umount "$part1" "$part2" 2>/dev/null || true
sudo dd if="$HOME/openmanet-sdcard-before-resize.img" of="$DISK" \
  bs=4M status=progress conv=fsync
sync
~~~

## 4. Identify partition 2 and its first-boot state

Choose the partition-device spelling for the whole disk you verified:

~~~sh
case "$DISK" in
  /dev/mmcblk*|/dev/nvme*) PART2="$DISK"p2 ;;
  *)                       PART2="$DISK"2  ;;
esac

printf 'Whole card: %s\nPartition 2: %s\n' "$DISK" "$PART2"
sudo parted -s "$DISK" unit s print
sudo blkid "$PART2" || true
~~~

Partition 2 begins with SquashFS. The factory image normally has no F2FS
signature in the unwritten space after SquashFS immediately after flashing;
the first boot initializes the writable overlay. This is why blkid PART2 may
report squashfs rather than f2fs.

There are two safe cases:

### Case A: F2FS already exists

This occurs on a card that has already booted, or on an image that includes an
initialized overlay. Expand the partition while it is offline, then run the
loop-device and F2FS procedure in section 6 before booting the Pi.

### Case B: F2FS does not exist yet

This is the normal freshly flashed-card case. First expand partition 2 while
the card is offline, then boot the Pi once so OpenMANET can initialize its
writable overlay. Complete the initial setup, shut the Pi down cleanly, and
return the card to Linux. Run section 6 then; the loop device should now report
TYPE="f2fs" with blkid.

If the loop device still does not identify as F2FS after a clean first boot,
stop. Do not run mkfs.f2fs, resize.f2fs, or fsck.f2fs against an unknown
device. Preserve the backup and investigate the image-specific layout.

## 5. Expand partition 2

Record partition 2's starting sector before changing anything:

~~~sh
PART2_START_BEFORE=$(sudo parted -ms "$DISK" unit s print | \
  awk -F: '$1 ~ /2$/ {sub(/s$/, "", $2); print $2; exit}')
test -n "$PART2_START_BEFORE"
printf 'Partition 2 start before: %ss\n' "$PART2_START_BEFORE"
~~~

Extend only partition 2 to the end of the card:

~~~sh
sudo parted -s "$DISK" unit s resizepart 2 100%
sudo partprobe "$DISK" || true
sudo udevadm settle
~~~

Confirm that the start did not move:

~~~sh
PART2_START_AFTER=$(sudo parted -ms "$DISK" unit s print | \
  awk -F: '$1 ~ /2$/ {sub(/s$/, "", $2); print $2; exit}')
printf 'Partition 2 start after:  %ss\n' "$PART2_START_AFTER"
test "$PART2_START_BEFORE" = "$PART2_START_AFTER"
sudo parted -s "$DISK" unit s print
~~~

If the start-sector check fails, stop and restore the backup. Do not continue.

## 6. Calculate the F2FS offset and create a loop device

The offset is relative to PART2, not to the whole SD card. Calculate it from
the SquashFS metadata every time; never copy an offset from another image.
unsquashfs -s reports the actual SquashFS byte length. The image builder
places the following data at the next 512-byte sector boundary:

~~~sh
SQUASHFS_BYTES=$(sudo unsquashfs -s "$PART2" 2>/dev/null | \
  awk '/^Filesystem size / {print $3; exit}')
case "$SQUASHFS_BYTES" in
  ''|*[!0-9]*)
    echo 'Could not read SquashFS size from partition 2' >&2
    exit 1
    ;;
esac

F2FS_OFFSET=$(( ((SQUASHFS_BYTES + 511) / 512) * 512 ))
PART2_BYTES=$(sudo blockdev --getsize64 "$PART2")
test "$F2FS_OFFSET" -lt "$PART2_BYTES"
printf 'SquashFS bytes: %s\nF2FS offset:   %s\nPartition:     %s\n' \
  "$SQUASHFS_BYTES" "$F2FS_OFFSET" "$PART2_BYTES"
~~~

The following command attaches only the bytes after SquashFS. It does not
mount anything:

~~~sh
LOOP=$(sudo losetup --find --show \
  --offset "$F2FS_OFFSET" \
  --sizelimit "$((PART2_BYTES - F2FS_OFFSET))" \
  "$PART2")
trap 'sudo losetup -d "$LOOP" 2>/dev/null || true' EXIT

printf 'Loop device: %s\n' "$LOOP"
sudo blkid "$PART2" || true
sudo blkid "$LOOP" || true
FSTYPE=$(sudo blkid -o value -s TYPE "$LOOP" 2>/dev/null || true)
~~~

Expected results are squashfs for PART2 and, when the overlay exists, f2fs for
LOOP.

## 7. Check and resize F2FS offline

Confirm that the loop device is not mounted before continuing:

~~~sh
if findmnt --source "$LOOP" >/dev/null 2>&1; then
  echo 'The F2FS loop device is mounted; aborting.' >&2
  exit 1
fi
test "$FSTYPE" = f2fs
~~~

Run a forced offline check first:

~~~sh
sudo fsck.f2fs -f "$LOOP"
~~~

If fsck.f2fs reports an unclean checkpoint and says that the image must be
mounted to replay its log, do exactly that once, then unmount cleanly. Do not
resize while it is mounted:

~~~sh
sudo mkdir -p /mnt/openmanet-f2fs
sudo mount -t f2fs "$LOOP" /mnt/openmanet-f2fs
sync
sudo umount /mnt/openmanet-f2fs
sudo fsck.f2fs -f "$LOOP"
~~~

If the second check reports an unrecoverable error, stop and restore the backup.

Resize the clean, unmounted filesystem to the available loop-device size:

~~~sh
sudo resize.f2fs "$LOOP"
sudo fsck.f2fs -f "$LOOP"
sudo blkid "$LOOP"
~~~

For a newly initialized F2FS filesystem that already spans the expanded
partition, resize.f2fs may report that no additional growth is needed. That
is acceptable; the final fsck.f2fs and blkid checks must still succeed.

## 8. Safely detach and eject the card

Unmount any temporary mount, detach the loop device, flush writes, and confirm
the card is no longer busy:

~~~sh
sudo umount /mnt/openmanet-f2fs 2>/dev/null || true
sudo losetup -d "$LOOP"
trap - EXIT
sync
sudo udevadm settle
sudo eject "$DISK" 2>/dev/null || true
~~~

For a macOS VM, shut down or detach the SD device from the VM after the Linux
commands finish, then run diskutil eject /dev/diskN on macOS. Reinsert the
card in the Pi only after it has been safely ejected.

## 9. Verify the expanded overlay after boot

Boot the Pi and connect over SSH. The overlay should now report the expanded
capacity:

~~~sh
df -h /overlay
mount | grep ' /overlay '
blkid
~~~

Create a small persistence marker, reboot normally, and check it again:

~~~sh
touch /overlay/openmanet-resize-test
sync
reboot
~~~

After reconnecting:

~~~sh
test -f /overlay/openmanet-resize-test && echo 'overlay data persisted'
df -h /overlay
~~~

If the Pi does not boot or the overlay is missing, power it off and restore the
complete backup before attempting further repair.

