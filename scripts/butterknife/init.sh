#!/bin/sh
# Note that /dev should be handled by devtmpfs
# Make sure this file will be executable

mount -t proc none /proc
mount -t sysfs sysfs /sys
udhcpc

while [ 1 ]; do
    dialog --menu "What do you want to do" 0 0 0 \
        provision       "Provision this machine" \
        shell           "Drop to shell" \
        reboot          "Reboot" \
        poweroff        "Shutdown" 2> /tmp/what_next
    clear
    case $(cat /tmp/what_next) in
        shell)
            sh
        ;;
        reboot)
            reboot -f
        ;;
        poweroff)
            poweroff -f
        ;;
        provision)
            provision
            sh
        ;;
    esac
done

