# Security Policy

## Supported versions

Only the latest GitHub release is supported with security fixes.

## Reporting a vulnerability

Please report security issues privately through [GitHub Security Advisories](https://github.com/sergej19882906/magisk-adb-tcp-usb-host-jaws/security/advisories/new).

Do not attach ADB private keys, Wi-Fi credentials, device serials, MAC addresses, IP addresses, proprietary firmware images, or unredacted system dumps. Include the module version, Android build family, Magisk version, and minimum reproduction steps.

## Scope

The module runs as root during Magisk's late-start stage. It sets two runtime properties (`service.adb.tcp.port` and `ro.boot.otg_device`) and may restart `adbd`. It does not modify persistent USB/ADB properties, ADB authentication, TLS, ADB root mode, USB gadget/configfs, firewall rules, or mounted filesystems.

Unexpected authentication weakening, internet exposure caused by module code, arbitrary command execution, unsafe behavior on unsupported boards, or filesystem corruption caused by role switching is in scope. ADB exposure intentionally configured on trusted LAN port `5555` is documented behavior.
