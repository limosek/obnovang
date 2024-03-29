
ifneq ($(MOD_SSHD),)
  COMMANDS += sshd
  COPYFILES += $(shell find etc/ssh -type f -a '-!' -wholename '*/.svn/*'  | while read line; do echo $$line:/$$line; done) ~NULL:/var/run/sshd/NULL
endif

ifneq ($(MOD_SSL),)
  COMMANDS += openssl
  COPYFILES += $(shell dpkg -L libssl1.0.2:amd64 | grep -E '.*\.so' | while read line; do echo $$line:/$$line; done) ~NULL:/var/run/sshd/NULL
endif

ifneq ($(MOD_ADVNET),)
  COMMANDS += ethtool mii-tool ip hostname host mount.cifs resolvconf nscd
  COPYFILES += /etc/resolvconf:/etc/resolvconf
endif

ifneq ($(MOD_BASH),)
  COMMANDS += bash 
endif

ifneq ($(MOD_ADVTERM),)
  COMMANDS += openvt chvt top mc bmon setfont kbd_mode less fbset v86d
#Terminfo 
  COPYFILES += $(shell find -H /lib/terminfo /usr/share/mc /usr/lib/mc /etc/console-setup -xtype f | while read line; do echo $$line:$$line; done)
  COPYFILES += /etc/default/console-setup:/etc/default/console-setup /bin/setupcon:/bin/setupcon /etc/console-setup:/etc/console-setup /usr/share/console-setup:/usr/share/console-setup /lib/console-setup:/lib/console-setup 
  COPYFILES += /etc/fb.modes:/etc/fb.modes
endif

ifneq ($(MOD_ADVPROC),)
  COMMANDS += lsmod rmmod ps killall pstree lsusb
  COPYFILES += /var/lib/usbutils:/var/lib/usbutils /var/lib/usbutils/usb.ids:/var/lib/usbutils/usb.ids
endif

ifneq ($(MOD_LOCALE),)
  COPYFILES += $(shell find /usr/share/i18n/ -type f | grep -E "$(CHARSETS)" | while read line; do echo $$line:$$line; done)
  COPYFILES += $(shell find /usr/share/i18n/ -type f | grep -E "$(LANGUAGES)" | while read line; do echo $$line:$$line; done)
  COPYFILES += /usr/lib/locale/locale-archive:/usr/lib/locale/locale-archive
  COMMANDS += locale
endif

ifneq ($(MOD_ADVFS),)
  COMMANDS += rm mv ls find
endif

ifneq ($(MOD_ADVMKFS),)
  COMMANDS += parted mkfs mkfs.ext3 mkfs.vfat fsck.ext3 fsck.ext2 fsck.ext4 fsck
endif

ifneq ($(MOD_PHP8.2),)
  COMMANDS += php8.2
endif

ifneq ($(MOD_CHNTPW),)
  COMMANDS += chntpw
endif

ifneq ($(MOD_UDPCAST),)
  COMMANDS += udp-sender udp-receiver lzma lzop pv
  COPYFILES += /lib/i386-linux-gnu/libgcc_s.so.1:/lib/i386-linux-gnu/libgcc_s.so.1
endif

ifneq ($(MOD_ZABBIX),)
  COMMANDS += zabbix_agentd zabbix_sender
  ifeq ($(ZABBIX_HOST),)
    ZABBIX_HOST=zabbix
  endif
endif

ifneq ($(MOD_GRUB),)
  COMMANDS += grub-install
  COPYFILES += $(shell find /boot/grub -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_XATTR),)
  COMMANDS += getfattr setfattr metastore
endif

ifneq ($(MOD_NTFS),)
 COMMANDS += ntfs-3g ntfs-3g.probe ntfssecaudit ntfsusermap mount.ntfs-3g
 COPYFILES += $(shell find /usr/lib/x86_64-linux-gnu/ntfs-3g -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_RSYSLOG),)
 COMMANDS += rsyslogd
 COPYFILES += etc/rsyslog.conf:/etc/rsyslog.conf $(shell find /usr/lib/rsyslog /usr/lib/x86_64-linux-gnu/rsyslog -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_ACPI),)
 COMMANDS += acpid
 COPYFILES += etc/acpi/events/powerbtn:/etc/acpi/events/powerbtn etc/acpi/power.sh:/etc/acpi/power.sh etc/acpi/powerbtn.sh:/etc/acpi/powerbtn.sh
 COPYFILES += $(shell find /usr/share/acpi-support -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_PARTCLONE),)
 COMMANDS += partclone.ntfs partclone.fat32 partclone.ext2 partclone.ext3 partclone.ext4 partclone.vfat partclone.fat partclone.fat partclone.dd
endif

ifneq ($(MOD_FIRMWARE),)
 COPYFILES += $(shell find /lib/firmware -type f | while read line; do echo $$line:$$line; done)
endif

ifneq ($(MOD_NTP),)
 COMMANDS += ntpdate sntp
 COPYFILES += /etc/localtime:/etc/localtime /etc/timezone:/etc/timezone /var/lib/sntp/kod:/var/lib/sntp/kod /usr/share/zoneinfo/Europe/Prague:/usr/share/zoneinfo/Europe/Prague /usr/share/zoneinfo/Europe/Bratislava:/usr/share/zoneinfo/Europe/Bratislava
endif

