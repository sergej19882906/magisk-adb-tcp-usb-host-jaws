# ADB TCP + USB Host for Xiaomi Jaws

[Русская версия](README.ru.md)

A board-specific Magisk module for Xiaomi `MiTV-AFKR0` (`jaws`) that keeps the external USB-A port in host mode for storage while keeping ADB available over TCP port `5555`.

## Hardware limitation

The device has one external dual-role USB path. It cannot provide USB ADB to a computer and host a USB flash drive through that same physical port at the same time. This module uses:

- USB host mode for the flash drive;
- ADB over the local network.

A USB hub does not remove this host/device role limitation.

## Compatibility

The installer intentionally accepts only:

- product device: `jaws`;
- SoC: `AMLS905X4`;
- readable Xiaomi vendor USB switch: `/sys/class/gpio/gpio474/direction`.

Tested on:

- Xiaomi `MiTV-AFKR0`;
- Android 14 / build family `UKG3`;
- Magisk 31.1;
- SELinux enforcing;
- a FAT32 USB flash drive mounted through Android's StorageManager.

Do not bypass the compatibility check on another device. GPIO 474 and the `ro.boot.otg_device` trigger are specific to this board and firmware family.

## Security warning

ADB TCP listens on network interfaces at port `5555`. Use it only on a trusted LAN:

- do not forward port `5555` from a router to the internet;
- do not disable ADB RSA authentication;
- review authorized ADB computers;
- disable or uninstall the module when network ADB is no longer needed.

The module does not change ADB root, authentication, TLS, persistent USB properties, gadget/configfs, or firewall rules.

## Installation

1. Download the installable ZIP and `SHA256SUMS` from the latest [GitHub release](https://github.com/sergej19882906/magisk-adb-tcp-usb-host-jaws/releases/latest).
2. Verify the ZIP checksum.
3. Install the ZIP through **Magisk → Modules → Install from storage**.
4. Reboot the device.
5. Connect over the network:

```sh
adb connect DEVICE_IP:5555
```

Do not install GitHub's automatically generated **Source code** archive. Use the ZIP attached to the release.

## Verification

Replace `DEVICE_IP` with the address of the Android TV device:

```sh
adb connect DEVICE_IP:5555
adb -s DEVICE_IP:5555 shell getprop init.svc.adbd
adb -s DEVICE_IP:5555 shell getprop service.adb.tcp.port
adb -s DEVICE_IP:5555 shell cat /sys/class/gpio/gpio474/direction
adb -s DEVICE_IP:5555 shell sm list-volumes all
```

Expected state:

- `adbd`: `running`;
- ADB port: `5555`;
- GPIO direction: `out`;
- the USB drive appears as a mounted public volume.

Module log:

```sh
su -c 'cat /data/adb/modules/adb_tcp_usb_host_jaws/service.log'
```

## How it works

The late-start service maintains three runtime invariants:

1. `service.adb.tcp.port=5555`;
2. `ro.boot.otg_device=2`;
3. `adbd` is running and the vendor GPIO switch reports `out`.

When a correction is needed, it restarts `adbd` once so Xiaomi's vendor init rule applies the USB host switch. The watchdog checks again every 30 seconds and does not restart `adbd` while the state is already correct.

All changes are runtime-only. The module does not write `persist.*` USB/ADB properties.

## Disable and uninstall

1. **Safely eject the USB drive in Android settings.**
2. Disable or remove the module in Magisk.
3. Reboot.

Do not switch the port back to device mode while a filesystem is mounted. The uninstall script only stops the watchdog; normal firmware defaults return after reboot.

## Troubleshooting

### ADB disconnects briefly after boot

One short disconnect is expected when `adbd` restarts to apply TCP and host mode. The watchdog then keeps the daemon running.

### The flash drive is not mounted

Check power requirements, filesystem support, and Android StorageManager:

```sh
sm list-disks
sm list-volumes all
```

High-current disks may require a powered hub. A hub still does not enable simultaneous USB ADB and USB host mode.

### Network ADB does not reconnect

Confirm Wi-Fi/Ethernet connectivity and port `5555`. If necessary, use the local Android UI to disable the module and reboot. The module intentionally does not weaken ADB authentication or alter firewall policy.

## Build from source

Python 3 is the only build dependency:

```sh
python scripts/build.py
python scripts/verify.py
```

Outputs:

```text
dist/magisk-adb-tcp-usb-host-jaws-vX.Y.Z.zip
dist/SHA256SUMS
```

The build is byte-for-byte reproducible.

## License

[MIT](LICENSE) © 2026 sergej19882906
