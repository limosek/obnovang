#!/bin/sh

test -f /usr/share/acpi-support/key-constants || exit 0

. /usr/share/acpi-support/policy-funcs
. /etc/common-functions
killall obnova >/dev/null 2>/dev/null 
killall zaloha >/dev/null 2>/dev/null 

exitfunc 0 halt  </dev/tty2 >/dev/tty2


