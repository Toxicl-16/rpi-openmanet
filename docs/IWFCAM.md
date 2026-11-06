# IWFCam on Raspberry Pi 3B+

The Pi 3B+ image includes `iwfcam-rtsp`, a small service that converts the
IWFCam camera's local UDP H.264 stream into RTSP. It does not depend on cloud
discovery or Internet access.

## Automatic startup

The service is enabled at boot and waits until the configured camera MAC is
visible either as a Wi-Fi station or a local neighbor entry. This prevents a
boot race when the camera powers up after the Pi.

Default configuration:

```text
camera IP:  10.41.0.101
camera MAC: c6:26:08:13:2e:23
RTSP port:  8554
```

Change it with UCI if the camera has a different address or MAC:

```sh
uci set iwfcam.main.camera_ip='10.41.0.101'
uci set iwfcam.main.camera_mac='aa:bb:cc:dd:ee:ff'
uci commit iwfcam
/etc/init.d/iwfcam restart
```

Check startup and detection:

```sh
/etc/init.d/iwfcam status
logread | grep iwfcam
ip neigh show | grep -i 'c6:26:08:13:2e:23'
```

## RTSP address

From an EUD on the same MANET, use:

```text
rtsp://10.41.0.2:8554/cam
```

Replace `10.41.0.2` with the node's actual MANET address. Select RTSP
TCP/interleaved transport where the client offers that choice; it is more
resilient to packet loss on a long-range HaLow link.

The camera's tested stream is H.264 at 1280×720 and approximately 0.7 Mbps.
The bridge does not require the camera to reach the Internet. Local manual
RTSP playback works even when the WAN path is unavailable. Vendor cloud-based
discovery may still require Internet and is separate from this service.

## Troubleshooting

```sh
iw dev phy1-ap0 station dump
ip neigh show dev br-ahwlan
pgrep -af iwfcam
netstat -lntup | grep 8554
logread | grep -E 'iwfcam|H264'
```

If the MAC is not visible, check camera power, SSID/key, and that the camera
is associated with the node's local AP. The service intentionally waits rather
than opening an empty RTSP endpoint.
