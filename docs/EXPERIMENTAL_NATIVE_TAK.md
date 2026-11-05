# Experimental native TAK service

This branch replaces the Docker-based OpenTAKServer deployment in the Pi 5
image with [GolangTAKServer](https://github.com/grangedevgroup-code/TAK-Backend),
a single native ARM64 binary. It is an experimental alternative; it does not
change the stable `v0.5.4-rpi5-safe` release.

## What is included

- GolangTAKServer 1.6.3 for Linux ARM64
- OpenWrt `procd` service: `/etc/init.d/golangtakserver`
- Persistent data under `/opt/golangtakserver`
- No Docker, Compose, database server, or OpenTAKServer package
- Video and voice listeners disabled in the initial profile to keep the Pi 5
  service lightweight

The binary and its upstream 0BSD license are installed in
`/opt/golangtakserver`. The package Makefile pins the release SHA-256 before
the binary can enter the firmware.

## First boot

The service starts automatically after networking. On its first start it
creates the certificate authority, server certificate, and administrator
account. Read the generated administrator password over SSH:

```sh
cat /opt/golangtakserver/admin-password.txt
```

Open the dashboard at `https://PI_ADDRESS:8446`. The server also provides a
secure HTTPS dashboard on port `8443`. Plain TCP, UDP, and HTTP are disabled in
the default profile. Port `8080` is intentionally not used by this service.

TAK clients use:

| Function | Port |
| --- | ---: |
| TLS CoT for ATAK/iTAK/WinTAK | 8089 |
| WebSocket | 8091 |
| HTTPS API/dashboard | 8443 |
| Certificate enrollment | 8446 |
| REST/API compatibility | 19023 |

Use the dashboard to create a connection package or enrollment QR code. For
an IP-only deployment, a connection package carrying the server trust store is
the safest way to configure clients because a public certificate cannot be
issued for a bare private IP address.

## Service checks

```sh
/etc/init.d/golangtakserver status
ps w | grep '[g]olangtakserver'
logread | grep -i golangtakserver
cat /opt/golangtakserver/admin-password.txt
```

The detailed application log is stored at
`/opt/golangtakserver/logs/golangtakserver.log`. The server also has built-in
diagnostics:

```sh
/usr/bin/golangtakserver status --data /opt/golangtakserver
/usr/bin/golangtakserver selftest --data /opt/golangtakserver
```

## Experimental limitations

This firmware was compiled and inspected on the Ubuntu build server. It was
not booted or tested against ATAK or iTAK on physical Pi 5 hardware in this
environment. The first hardware test should verify the service, dashboard,
TLS enrollment, and a real CoT exchange before this branch is considered a
replacement for the stable Docker/OpenTAKServer image.

The native service does not provide the OpenTAKServer-specific UI, PostGIS
database, RabbitMQ deployment, or media services. Keep the stable image if
those features are required.

The default profile disables anonymous access and unencrypted TAK/dashboard
listeners. Use the TLS listener and a generated client connection package or
enrollment QR code for ATAK and iTAK.
