# Experimental native TAK service

This image replaces the Docker-based OpenTAKServer deployment in the Pi 5
image with [GolangTAKServer](https://github.com/grangedevgroup-code/TAK-Backend),
a single native ARM64 binary.

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

## First boot and credentials

The service starts automatically after networking. During the initial
OpenMANET setup wizard, set a non-empty password for the system `root` account.
The wizard temporarily passes that same password to the native TAK package,
which creates or updates the GoLangTAKServer administrator account named
`root`. After a successful update, the temporary plaintext UCI value is
deleted. The system password is not recovered from `/etc/shadow`, because
Linux stores only a one-way hash there.

If the wizard is completed without a password, the TAK account is not
synchronized. For a clean first test, factory-flash this release and complete
the wizard with the desired root password before opening the TAK dashboard.

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
/usr/bin/golangtakserver user list --data /opt/golangtakserver
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
