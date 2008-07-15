
KERNEL=$(PWD)/bin/obnovang.vmlinuz
INITRAMFS=$(PWD)/bin/obnovang.initramfs

ifeq ($(shell uname -m),x86_64)
QEMU = qemu-system-x86_64
WARN64=yes
else
QEMU = qemu
endif

COMMANDS += logger grep cut awk rsync reset wc chmod ssh ssh-add ssh-agent dhclient3 strace ldd
SCOMMANDS += hdparm ifconfig route ldconfig ldconfig.real dhclient-script
# Copy configs
COPYFILES += etc/group:/etc/group etc/nsswitch.conf:/etc/nsswitch.conf etc/passwd:/etc/passwd etc/initramfs-tools/init:/init etc/fstab:/etc/fstab etc/dhcp3/dhclient.conf:/etc/dhcp3/dhclient.conf /lib/dhcp3-client/call-dhclient-script:/lib/dhcp3-client/call-dhclient-script 

DEPCOMMANDS += mkinitramfs qemu gzip gunzip m4 gcc ld

# Include local config
include config.mk

include modules.mk

# ssh keys and config
COPYFILES += $(shell find etc/ssh -type f -a '-!' -wholename '*/.svn/*'  | while read line; do echo $$line:/$$line; done) /dev/null:/var/lib/sshd
#NSS files
COPYFILES += $(shell find /lib/libnss* -type f | while read line; do echo $$line:$$line; done)
# Obnova files
COPYFILES += src/obnova:/etc/init.d/obnova src/zaloha:/etc/init.d/zaloha src/main:/etc/init.d/main src/obnova-included.conf:/etc/obnova-included.conf src/rcS:/bin/obnovang-stage2 src/obnovang:/bin/obnovang src/obnovang:/sbin/init src/common-functions:/etc/common-functions
# Halt and reboot
COPYFILES += /sbin/halt:/bin/halt /sbin/poweroff:/bin/poweroff /sbin/reboot:/bin/reboot
# Modules
MODULES += ide-cd ide-disk iso9660 ata_piix libata cdrom sr_mod sd_mod sg scsi_mod usb-storage loop squashfs unionfs ext3 nbd nfs 3c509 3c515 3c59x 8139cp 8139too 82596 8390 ac3200 acenic amd8111e at1700 b44 bnx2 bsd_comp cassini cs89x0 dummy e100 e2100 eepro100 eepro eexpress epic100 mii natsemi ne2k-pci ne netconsole ni52 ni65 plip ppp_async ppp_deflate ppp_generic ppp_mppe pppoe pppox ppp_synctty r8169 rrunner s2io sb1000 seeq8005 sis190 sis900 skge slhc smc9194 smc-ultra tg3 tlan tun typhoon via-rhine via-velocity wd ext2 ext3 fat fuse isofs jbd jffs2 jffs jfs lockd minix msdos ncpfs nfs_acl nfs nls_ascii nls_cp1250 nls_cp1251 nls_cp1255 nls_cp437 nls_cp737 nls_cp775 nls_cp850 nls_cp852 nls_cp855 nls_cp857 nls_cp860 nls_cp861 nls_cp862 nls_cp863 nls_cp864 nls_cp865 nls_cp866 nls_cp869 nls_cp874 nls_cp932 nls_cp936 nls_cp949 nls_cp950 nls_euc-jp nls_iso8859-13 nls_iso8859-14 nls_iso8859-15 nls_iso8859-1 nls_iso8859-2 nls_iso8859-3 nls_iso8859-4 nls_iso8859-5 nls_iso8859-6 nls_iso8859-7 nls_iso8859-9 nls_koi8-r nls_koi8-ru nls_koi8-u nls_utf8 reiserfs romfs smbfs sysv udf vfat ide-generic mtdblock mtdram block2mtd

TESTCMD=if which $$cmd >/dev/null 2>/dev/null; then \
	  if [ -n "$(DEBUG)" ]; then echo "OK: " $$cmd '=>' $$(which $$cmd); fi; \
	  else \
	    miss=1; \
	    echo "Missing command: $$cmd"; \
	  fi

all: testconf testdeps kernel $(MOD_TARGETS) initramfs warn64

warn64:
	@if [ -n "$(WARN64)" ]; then \
	  echo "Warning! You are making 64bit obnova image!"; \
	fi

udpcast: bin/udp-sender bin/udp-receiver
bin/udp-sender:
	(cd udpcast-20071228; ./configure; make -j)
	cp udpcast-20071228/udp-sender bin/
bin/udp-receiver:
	cp udpcast-20071228/udp-receiver bin/

testconf:
	@if [ -n "$(NOTCONFIGURED)" ]; then \
	  echo "Obnova not configured! Run ./configure "; \
	  chmod +x configure; \
	  exit 1; \
	fi

testdeps:
	@for cmd in $(COMMANDS) $(DEPCOMMANDS) ; do \
	  $(TESTCMD) ; \
	done; \
	if [ -n "$$miss" ]; then echo "You have to resolve dependencies and install missing commands."; exit 1; fi

initramfs: $(INITRAMFS)
$(INITRAMFS): config.mk
	@find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f | xargs chmod +x
	@find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f -a -name '*~' | xargs rm -f
	@echo "Generating initramfs"
	@export debug=$(DEBUG) commands="$(COMMANDS)" scommands="$(SCOMMANDS)" copyfiles="$(COPYFILES)" modules="$(MODULES)"; \
	 mkinitramfs -d $(PWD)/etc/initramfs-tools -o $(INITRAMFS)
	@ls -lah $(KERNEL) $(INITRAMFS)
	
show:
	@find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f | xargs chmod +x
	@find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f -a -name '*~' | xargs rm -f
	@echo "Testing initramfs"
	@export debug=$(DEBUG) commands="$(COMMANDS)" scommands="$(SCOMMANDS)" copyfiles="$(COPYFILES)" modules="$(MODULES)"; \
	echo "commands: "; for c in $(COMMANDS); do echo -n " "$$c; done; \
	echo ; \
	echo "scommands: "; for c in $(SCOMMANDS); do echo -n " "$$c; done; \
	echo ; \
	echo "copyfiles: "; for c in $(COPYFILES); do echo -n " "$$c; done; \
	echo ; \
	echo "modules: "; for m in $(MODULES); do echo -n " "$$m; done; \
	echo ;

kernel: $(KERNEL)
$(KERNEL):
	cp /boot/vmlinuz-$(shell uname -r) $(KERNEL)

test: initramfs kernel
	$(QEMU) -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -net nic -net user -append 'root=/dev/ram rootdelay=1 obnovapath="193.84.208.21::obnova" quiet loglevel=0'

debugtest: initramfs kernel extract
	$(QEMU) -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -net nic -net user -append 'root=/dev/ram rootdelay=1 obnovapath="193.84.208.21::obnova"'

clean:
	rm -f $(INITRAMFS) $(KERNEL) bin/udp-sender bin/udp-receiver
	make -C udpcast-20071228 clean; true
	@find ./ -name '*~' | xargs rm -f

distclean: clean
	@echo 'NOTCONFIGURED = 1' >config.mk

extract:
	rm -rf /tmp/obnovang
	mkdir -p /tmp/obnovang
	cd /tmp/obnovang; \
	gunzip -c -9  $(INITRAMFS) | cpio -i -d -H newc --no-absolute-filenames
 	