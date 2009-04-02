#!/bin/sh
# Menu script for obnova

init ()
{
TXT=" (c)199X Pavel Běhal, pavel (at) behal.cz\\n"
TXT="$TXT (c)2003,2004 Lukáš Kubín, lukas.kubin (at) gmail.com\\n"
TXT="$TXT (c)2005,2006,2007,2008 Lukáš Macura, macura (at) opf.slu.cz\\n"
TXT="$TXT (c)2008? Tomáš Králík, runyar (at) gmail.com\\n"
TXT="$TXT (c)2008 Jakub Ježíšek, Pavel Bačo (annoying testers)\\n"
TXT="$TXT Slezská univerzita v Opavě\\n"
dialog --backtitle 'SYSTÉM OBNOVY SKUPIN POČÍTAČOVÝCH STANIC' --begin 1 1 --ascii-lines --infobox "$TXT" 10 80
}

case $1 in

init)
	init()
	;;

esac
