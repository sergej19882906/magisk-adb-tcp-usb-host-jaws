# Changelog

All notable changes to this project are documented in this file.

## [1.0.0] - 2026-11-09

### Added

- First public release.
- Board-specific compatibility checks for Xiaomi `jaws` / AMLS905X4.
- Runtime ADB TCP port `5555` enforcement without persistent property changes.
- Xiaomi vendor USB host role activation through `ro.boot.otg_device=2`.
- Watchdog recovery when `adbd` stops or the runtime role drifts.
- Reproducible ZIP builder, verifier, bilingual documentation, and CI.
