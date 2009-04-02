#!/bin/sh

# Init script of obnovang. It is run after initramfs finds anything usefull (HW, proc,...)

# Load out functions
. /ong/functions.sh
# Load initramfs functions
. /scripts/functions
# Load default config variables
. /ong/defaults.cfg
set -a

# Run menu script
/ong/menu.sh prerun || oerrexit "Cannot run preinit menu"

# Initialize IP and set parameters $ip,$hostname,$ipgw,$mac,$domain
ipinit || oerrexit "Cannot get IP"

# Fetch config file (global even local)
fetchconfigfile || oerrexit "Cannot fetch config file"

# And load parameters
. /tmp/obnovang.cfg
set -a

# Run menu script
/ong/menu.sh run || oerrexit "Error runing init menu"

# Include config changed by menu
. /tmp/menu.cfg
set -a

case $o_method in
rsync)
	/ong/obnovang.sh rsync || oerrexit "Error runing obnova main script"
	;;
rsync-sender)
	/ong/obnovang-admin.sh rsync || oerrexit "Error runing obnova admin script"
	;;
esac

/ong/menu.sh postrun || oerrexit "Error runing postrun menu"

oexit "Normal exit"

