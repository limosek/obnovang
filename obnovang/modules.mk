
ifneq ($(MOD_SSHD),)
  COMMANDS += sshd
  COPYFILES += $(shell find etc/ssh -type f -a '-!' -wholename '*/.svn/*'  | while read line; do echo $$line:/$$line; done) ~NULL:/var/run/sshd/NULL
endif

ifneq ($(MOD_ADVNET),)
  COMMANDS += ethtool mii-tool ip hostname host
endif

ifneq ($(MOD_BASH),)
  COMMANDS += bash
endif

ifneq ($(MOD_ADVTERM),)
  COMMANDS += openvt chvt top mc iftop setfont kbd_mode less
#Terminfo 
  COPYFILES += $(shell find -H /usr/share/terminfo /usr/share/mc /usr/lib/mc /etc/console-tools /etc/console-setup -xtype f | while read line; do echo $$line:$$line; done)
  COPYFILES += /etc/default/console-setup:/etc/default/console-setup src/old/setupcon:/bin/setupcon
endif

ifneq ($(MOD_ADVPROC),)
  COMMANDS += lsmod rmmod ps killall pstree
endif

ifneq ($(MOD_LOCALE),)
  COPYFILES += $(shell find /usr/lib/locale/cs_CZ.utf8 -type f | while read line; do echo $$line:$$line; done)
  COMMANDS += locale
endif

ifneq ($(MOD_ADVFS),)
  COMMANDS += rm mv ls find
endif

ifneq ($(MOD_ADVMKFS),)
  COMMANDS += parted mkfs mkfs.ext3 mkfs.vfat 
endif

ifneq ($(MOD_PHP5),)
  COMMANDS += php5
endif

ifneq ($(MOD_CHNTPW),)
  COMMANDS += chntpw
endif

ifneq ($(MOD_UDPCAST),)
  COMMANDS += udp-sender udp-receiver lzma lzop dd_rescue
  MOD_DEPS += udpcast
  MOD_PRE_DEPS += udpcast
endif

ifneq ($(MOD_ZABBIX),)
  COMMANDS += zabbix_agentd zabbix_sender
endif

ifneq ($(MOD_GRUB),)
  COMMANDS += grub grub-install
  COPYFILES += $(shell find /boot/grub -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_XATTR),)
  COMMANDS += getfattr setfattr metastore
endif

ifneq ($(MOD_NTFS),)
 COMMANDS += ntfs-3g ntfs-3g.probe ntfs-3g.secaudit ntfs-3g.usermap mount.ntfs-3g
endif

ifneq ($(MOD_RSYSLOG),)
 COMMANDS += rsyslogd
 COPYFILES += etc/rsyslog.conf:/etc/rsyslog.conf $(shell find /usr/lib/rsyslog -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_ACPI),)
 COMMANDS += acpid
 COPYFILES += etc/acpi/events/powerbtn:/etc/acpi/events/powerbtn etc/acpi/power.sh:/etc/acpi/power.sh etc/acpi/powerbtn.sh:/etc/acpi/powerbtn.sh
 COPYFILES += $(shell find /usr/share/acpi-support -type f | while read line; do echo $$line:$$line; done)
endif
