#!/bin/sh
# /etc/acpi/powerbtn.sh
# Initiates a shutdown when the power putton has been
# pressed.

[ -r /usr/share/acpi-support/power-funcs ] && . /usr/share/acpi-support/power-funcs

. /etc/common-functions
killall obnova >/dev/null 2>/dev/null 
killall zaloha >/dev/null 2>/dev/null 

exitfunc 0 halt </dev/tty2 >/dev/tty2


