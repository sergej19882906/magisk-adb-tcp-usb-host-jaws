#!/system/bin/sh

DEVICE=$(/system/bin/getprop ro.product.device)
SOC=$(/system/bin/getprop ro.soc.model)
GPIO=/sys/class/gpio/gpio474/direction
MAGISK_BIN=/data/adb/magisk/magisk

if [ "$DEVICE" != jaws ] || [ "$SOC" != AMLS905X4 ]; then
  abort "! Unsupported device: $DEVICE / $SOC"
fi

if [ ! -x "$MAGISK_BIN" ] || [ ! -r "$GPIO" ]; then
  abort "! Required Magisk or USB role control is unavailable"
fi

set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
