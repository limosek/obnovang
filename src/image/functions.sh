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

#
# Logging function
#
log ()
{
	if [ "$1" -eq 1 ]; then
		lbg=
		lend=
	else if [ "$1" -eq 2 ]; then
		lbg="*"
		lend="*"
	else
		lbg="!"
		lend="!"
	fi
	echo "${lbg}${2}${end}" >/dev/tty7
	[ "$o_syslogserver" = "" ] && return 0 # Do nothing if logging daemon not running
	if [ "$1" -le $o_loglevel ]; then
		logger -t obnovang "$2"
		echo ${lbg}${2}${lend}
	fi
}

zlog ()
{
  if [ -z "$o_zabbixserver" ] || [ -z "$o_zabbixservermyhostname" ]; then
    true
  else
    if ! zabbix_sender -z "$o_zabbixserver" -p "$o_zabbixserverport" -s "$o_zabbixservermyhostname" -k "$o_zabbixserveritem" -o "$1" >&2; then
      log 2 "Zabbix communication error!";
    fi
  fi
}


# Init IP and variables
ipinit ()
{
# Setup loop device
  ifconfig lo 127.0.0.1 netmask 255.0.0.0
# If static IP used on commandline
  ip=$(getcmdvar ip)
  ipmask=$(getcmdvar ipmask)
  ipgw=$(getcmdvar ipgw)
  dns=$(getcmdvar dns)
  domain=$(getcmdvar domain)
  if [ -n "$ip" ]; then
	ifconfig eth0 $ip netmask $ipmask
	ip route add 0.0.0.0/0 via $ipgw
	echo "search $domain" >/etc/resolv.conf
	echo "nameserver $dns" >>/etc/resolv.conf
  else
    dhclient -lf /tmp/dhcp eth0
    ip=$(LANG=en ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}');
    if [ -z "$ip" ]; then
	oerrexit E_NOIP
    fi
    hostname=$(LANG=en host $ip | cut -d ' ' -f 5)
    dns=$(grep nameserver /etc/resolv.conf | cut -d ' ' -f 2)
    mac=$(LANG=en ifconfig | grep 'HWaddr'| cut -s ' ' | cut -d' ' -f5 | awk '{ print $1}');
    dhclient -6 -lf /tmp/dhcp6 eth0 &
    true
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
lcfgurl=$(getcmdvar lcfgurl)
lcfgurl2=$(getcmdvar lcfgurl2)

# Next we lookup for global config variables (for group)
gcfgurl=$(getcmdvar gcfgurl)
gcfgurl2=$(getcmdvar gcfgurl2)

# And o_server variable
server=$(getcmdvar server)

# And o_group variable
group=$(getcmdvar group)

# If o_server was on commandline, we have cfg url
if [ -n "$server" ] ; then
	servercfg=rsync://$server/cfg/
	serverdata=rsync://$server/data/
	if [ -z "$group" ]; then
		fetchurl ${servercfg}/group2mac.txt /tmp/group2mac.txt
		group=$(grep $mac /tmp/group2mac.txt | cut -d ',' -f 1)
		if [ -z "$group" ]; then
			oerrexit E_NOTINDB
		fi
	fi
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
r	eason=$1
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

