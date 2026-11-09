#!/system/bin/sh

MODDIR=${0%/*}
LOG_FILE="$MODDIR/service.log"
PID_FILE="$MODDIR/service.pid"
MAGISK_BIN=/data/adb/magisk/magisk
GETPROP=/system/bin/getprop
SETPROP=/system/bin/setprop
SLEEP=/system/bin/sleep
SS=/system/bin/ss
GPIO=/sys/class/gpio/gpio474/direction
ADB_PORT=5555

cleanup() {
  rm -f "$PID_FILE"
}

log() {
  echo "$(date): $*"
}

has_listener() {
  [ -x "$SS" ] || return 0
  "$SS" -lnt 2>/dev/null | grep -q ":$ADB_PORT "
}

trap cleanup EXIT INT TERM
umask 077
echo $$ > "$PID_FILE"
exec > "$LOG_FILE" 2>&1
log "start"
log "context: $(id)"

if [ "$($GETPROP ro.product.device)" != jaws ] || [ "$($GETPROP ro.soc.model)" != AMLS905X4 ]; then
  log "error: unsupported device"
  exit 1
fi

if [ ! -x "$MAGISK_BIN" ] || [ ! -r "$GPIO" ]; then
  log "error: required Magisk or USB role control is unavailable"
  exit 1
fi

last_state=

while true; do
  if [ -f "$MODDIR/disable" ] || [ -f "$MODDIR/remove" ]; then
    log "module disabled or marked for removal; runtime state will reset on reboot"
    exit 0
  fi

  port=$($GETPROP service.adb.tcp.port)
  adbd=$($GETPROP init.svc.adbd)
  otg=$($GETPROP ro.boot.otg_device)
  gpio=$(/system/bin/cat "$GPIO" 2>/dev/null)
  restart=false

  if [ "$port" != "$ADB_PORT" ]; then
    "$MAGISK_BIN" resetprop service.adb.tcp.port "$ADB_PORT"
    restart=true
  fi

  if [ "$otg" != 2 ]; then
    "$MAGISK_BIN" resetprop ro.boot.otg_device 2
    restart=true
  fi

  if [ "$adbd" != running ] || [ "$gpio" != out ] || ! has_listener; then
    restart=true
  fi

  if $restart; then
    log "applying ADB TCP $ADB_PORT and USB host mode"
    $SETPROP ctl.restart adbd
    $SLEEP 3
    port=$($GETPROP service.adb.tcp.port)
    adbd=$($GETPROP init.svc.adbd)
    otg=$($GETPROP ro.boot.otg_device)
    gpio=$(/system/bin/cat "$GPIO" 2>/dev/null)
  fi

  state="port=$port adbd=$adbd otg=$otg gpio=$gpio"
  if [ "$state" != "$last_state" ]; then
    log "$state"
    last_state=$state
  fi

  if [ "$port" != "$ADB_PORT" ] || [ "$adbd" != running ] || [ "$otg" != 2 ] || [ "$gpio" != out ]; then
    log "warning: expected runtime state not reached"
  fi

  $SLEEP 30
done
