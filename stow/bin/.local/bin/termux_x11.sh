#!/system/bin/sh

! [ "`id -u`" = 0 ] && echo "Must be ran under root!" && exit 1
[ "$1" = gl4es ] && LDPRELOAD=/data/data/com.termux/files/usr/lib/libGL.so.727

/system/bin/setenforce 0
TMPDIR=/mnt/.mystery_mount/kali/tmp
export CLASSPATH=$(/system/bin/pm path com.termux.x11 | cut -d: -f2)
export XKB_CONFIG_ROOT=/mnt/.mystery_mount/kali/usr/share/X11/xkb
export TERMUX_X11_DEBUG=1

LD_PRELOAD=${LDPRELOAD:-LD_PRELOAD} /system/bin/app_process / --nice-name=termux-x11 com.termux.x11.CmdEntryPoint :1
