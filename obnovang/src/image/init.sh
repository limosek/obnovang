#!/bin/sh

# Init script of obnovang. It is run after initramfs finds anything usefull (HW, proc,...)

# Load out functions
. /ong/functions.sh
# Load initramfs functions
. /scripts/functions
# Load default config variables
. /ong/defaults.cfg

# Initialize IP and set parameters $ip,$hostname,$ipgw,$mac,$domain
ipinit
# Fetch config file (global even local)
fetchconfigfile
# And load parameters
. /tmp/obnovang.cfg

