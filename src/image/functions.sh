#!/bin/sh

# Functions used by obnovang system.

# Get parameter value from kernel commandline
# Parameters: name
# Example: getkernelparm o_server will return its value on stdout
getcmdvar () {
  cat /proc/cmdline | tr ' ' '\n' | grep "$1=" | cut -d '=' -f 2
}

# Get parameter flag from kernel commandline
# Parameters: name
# Returns true or false
getcmdflag () {
  cat /proc/cmdline | tr ' ' '\n' | grep -E "^$1\$"
}

# Init IP and variables
ipinit ()
{
  
}

# Fetch file from location url into file
# It can be rsync:// , ftp:// , tftp:// , http:// or https://
# Parameters: url file
fetchurl ()
{
url=$1
file=$2
case $url in
http://*|ftp://*|https://*|tftp://*)
	curl -k $url 2>$o_tracefile >$file
	;;
rsync://*)
	rm -rf /tmp/fu$$
	mkdir /tmp/fu$$
	rsync $url /tmp/fu$$ 2>$o_tracefile
	mv /tmp/fu$$/* $file
	;;
/*)
	url=${o_cfgpath}${url}
	fetchurl $url $file
	;;
esac
}

fetchconfigfile ()
{
# First we lookup for local config variables (specific for this host)
lcfgurl1=$(getcmdvar o_lcfgurl1)
lcfgurl2=$(getcmdvar o_lcfgurl2)

# Next we lookup for global config variables (for group)
gcfgurl1=$(getcmdvar o_gcfgurl1)
gcfgurl2=$(getcmdvar o_gcfgurl2)

# And o_server variable
o_server=$(getcmdvar o_server)

# If o_server was on commandline, we have cfg url
if [ -n "$o_server" ] ; then
	o_cfgpath=rsync://$o_server/cfg/
fi
# If some cfg url is on commandline, it has precedence
if [ -n "$gcfgurl1" ]; then
	fetchurl $gcfgurl1 /tmp/gcfg1.cfg
fi
if [ -n "$gcfgurl2" ]; then
	fetchurl $gcfgurl2 /tmp/gcfg2.cfg
fi
if [ -n "$lcfgurl1" ]; then
	fetchurl $lcfgurl1 /tmp/lcfg1.cfg
else
	fetchurl /$domain/$mac.cfg /tmp/lcfg1.cfg
fi
if [ -n "$lcfgurl2" ]; then
	fetchurl $lcfgurl2 /tmp/lcfg2.cfg
else
	fetchurl /$domain/$o_group.cfg /tmp/lcfg2.cfg
fi
cat /tmp/gcfg2.cfg /tmp/gcfg1.cfg /tmp/lcfg2.cfg /tmp/lcfg1.cfg >/tmp/obnovang.cfg
}

oerrexit ()
{
reason=$1;
	dialog --title "$t_oerrexit" --infobox "$reason\n$o_posterrinfo" "$LINES" "$COLUMNS"
	osysexit $o_errexit
}

oexit ()
{
reason=$1;
	dialog --title "$t_oexit" --infobox "$reason\n$o_postinfo" "$LINES" "$COLUMNS"
	osysexit $o_exit

}

otimeoutexit ()
{
reason=$1
	dialog --title "$t_otimeoutexit" --infobox "$reason\n$o_posttimeoutinfo" "$LINES" "$COLUMNS"
	osysexit $o_timeoutexit
}

osysexit ()
{
type=$1
case $type in
halt)
	sleep $o_infotime
	halt
	;;
waithalt)
	sleep $o_waittime
	halt
	;;
reboot)
	sleep $o_infotime
	reboot
	;;
reboothalt)
	sleep $o_waittime
	reboot
	;;
wait)
	while true; do
		sleep 3600
	done
}

