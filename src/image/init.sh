#!/bin/sh

# Init script of obnovang. It is run after initramfs finds anything usefull (HW, proc,...)

# Load out functions
. /ong/functions.sh
# Load initramfs functions
. /scripts/functions
# Load default config variables
. /ong/defaults.cfg

# Initialize IP and set parameters $ip,$mac,$domain
ipinit
# Fetch config file (global even local)
fetchconfigfile
# And load parameters
. /tmp/obnovang.cfg

if [ -z "$o_group" ]; then
	fetchurl ${o_cfgpath}/group2mac.txt /tmp/group2mac.txt
	o_group=$(grep $mac /tmp/group2mac.txt | cut -d ',' -f 1)
	if [ -z "$o_group" ]; then
		oerrexit "Pocitac nenalezen v obnove."
	fi
fi

