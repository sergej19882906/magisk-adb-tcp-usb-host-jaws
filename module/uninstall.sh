#!/system/bin/sh

MODDIR=${0%/*}
PID_FILE="$MODDIR/service.pid"
EXPECTED_PATH="$MODDIR/service.sh"

: > "$MODDIR/disable"
pid=$(/system/bin/cat "$PID_FILE" 2>/dev/null)
case "$pid" in
  *[!0-9]*|'') ;;
  *)
    cmdline=$(/system/bin/tr '\000' ' ' < "/proc/$pid/cmdline" 2>/dev/null)
    case "$cmdline" in
      *"$EXPECTED_PATH"*) /system/bin/kill "$pid" 2>/dev/null || true ;;
    esac
    ;;
esac

# All ADB TCP and USB host changes are runtime-only.
# Safely eject USB storage and reboot to restore firmware defaults.
