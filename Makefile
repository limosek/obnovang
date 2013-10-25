
KERNEL=$(PWD)/bin/obnovang.vmlinuz
INITRAMFS=$(PWD)/bin/obnovang.initramfs
KVERSION=$(shell uname -r)

ifeq ($(shell uname -m),x86_64)
QEMU = qemu-system-x86_64
WARN64=yes
else
QEMU = qemu-system-i386
endif

SVNREVISION = $(shell svn info | grep Revision)

CHARSETS = $(shell echo $$LANG| cut -d '.' -f 2)
LANGUAGES = $(shell echo $$LANG| cut -d '.' -f 1)

COMMANDS += logger grep cut awk rsync reset wc chmod chown ssh ssh-add ssh-agent dhclient strace ldd dialog tar sed tr tee ping tracepath curl
SCOMMANDS += hdparm ifconfig route ldconfig ldconfig.real dhclient-script mknod umount shutdown halt poweroff reboot
# Copy configs
COPYFILES += etc/group:/etc/group etc/nsswitch.conf:/etc/nsswitch.conf etc/passwd:/etc/passwd etc/initramfs-tools/init:/init etc/fstab:/etc/fstab etc/rsyncd.conf:/etc/rsyncd.conf
COPYFILES += /var/lib/dhcp/dhclient.leases:/var/lib/dhcp/dhclient.leases
DEPCOMMANDS += mkinitramfs $(QEMU) gzip gunzip m4 gcc ld curl
GRUBMODULES = pxe pxecmd acpi afs at_keyboard biosdisk bitmap bitmap_scale blocklist boot bsd btrfs cat cmp configfile cpio cpuid crypto datehook date datetime drivemap efiemu echo elf extcmd ext2 fat font fshelp gcry_crc gcry_des gcry_md4 gcry_md5 gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool gettext gfxmenu gfxterm gptsync gzio halt hashsum hdparm help hexdump hwmatch chain iso9660 jpeg keylayouts keystatus legacycfg linux linux16 loadenv loopback lsacpi lsapm lsmmap ls lspci lvm lzopio memdisk minicmd mmap msdospart multiboot multiboot2 normal ntfscomp ntfs ntldr part_bsd part_gpt part_msdos parttool password password_pbkdf2 png probe pxecmd pxe read reboot regexp reiserfs relocator search_fs_file search_fs_uuid search_label search sendkey serial setjmp sleep squash4 tar terminal terminfo test_blockarg testload test true ufs1 ufs2 vbe vga vga_text video_fb videoinfo video video_bochs video_cirrus videotest xfs xzio 915resolution

# Include local config
include config.mk
include modules.mk
# If old obnova should be included into image
ifeq ($(OBNOVANG),)
  include oldobnova.mk
else
  COPYFILES += src/image/init.sh:/ong/init.sh src/image/init.sh:/sbin/init src/image/menu.sh:/ong/menu.sh src/image/obnovang.sh:/ong/obnovang.sh src/image/obnovang-admin.sh:/ong/obnovang-admin.sh src/image/functions.sh:/ong/functions.sh etc/ong/defaults.cfg:/ong/defaults.cfg
endif


# ssh keys and config
ifneq ($(SSHDIR),)
  COPYFILES += $(shell find $(SSHDIR) -type f -a '-!' -wholename '*/.svn/*'  | while read line; do echo $$line:/etc/ssh/`basename $$line`; done)
endif

#NSS files
COPYFILES += $(shell find /lib/libnss* /lib/i386-linux-gnu/*dns* -type f | while read line; do echo $$line:$$line; done)

# Modules
MODULES += unix eepro100 eexpress e1000e ide-cd ide-disk iso9660 ata_piix libata cdrom sr_mod sd_mod sg scsi_mod usb-storage loop squashfs unionfs ext3 nbd nfs 3c509 3c515 3c59x 8139cp 8139too 82596 8390 ac3200 acenic amd8111e at1700 b44 bnx2 bsd_comp cassini cs89x0 dummy e100 e2100 eepro100 eepro eexpress epic100 mii natsemi ne2k-pci ne netconsole ni52 ni65 plip ppp_async ppp_deflate ppp_generic ppp_mppe pppoe pppox ppp_synctty r8169 rrunner s2io sb1000 seeq8005 sis190 sis900 skge slhc smc9194 smc-ultra e100 e1000 e2100 tg3 tlan tun typhoon via-rhine via-velocity wd ext2 ext3 fat fuse isofs jbd jffs2 jffs jfs lockd minix msdos ncpfs nfs_acl nfs nls_ascii nls_cp1250 nls_cp1251 nls_cp1255 nls_cp437 nls_cp737 nls_cp775 nls_cp850 nls_cp852 nls_cp855 nls_cp857 nls_cp860 nls_cp861 nls_cp862 nls_cp863 nls_cp864 nls_cp865 nls_cp866 nls_cp869 nls_cp874 nls_cp932 nls_cp936 nls_cp949 nls_cp950 nls_euc-jp nls_iso8859-13 nls_iso8859-14 nls_iso8859-15 nls_iso8859-1 nls_iso8859-2 nls_iso8859-3 nls_iso8859-4 nls_iso8859-5 nls_iso8859-6 nls_iso8859-7 nls_iso8859-9 nls_koi8-r nls_koi8-ru nls_koi8-u nls_utf8 reiserfs romfs smbfs sysv udf vfat ide-generic mtdblock mtdram block2mtd atl1c cifs

TESTCMD=if which $$cmd >/dev/null 2>/dev/null; then \
	  if [ -n "$(DEBUG)" ]; then echo "OK: " $$cmd '=>' $$(which $$cmd); fi; \
	  else \
	    miss=1; \
	    echo " ====> Missing command: $$cmd"; \
	  fi

all: testconf testdeps kernel $(MOD_DEPS) initramfs warn64

warn64:
	@if [ -n "$(WARN64)" ]; then \
	  echo "Warning! You are making 64bit obnova image!"; \
	fi
	
testconf:
	@if [ -n "$(NOTCONFIGURED)" ]; then \
	  echo "Obnova not configured! Run ./configure "; \
	  chmod +x configure; \
	  exit 1; \
	fi

testdeps: $(MOD_PRE_DEPS)
	@PATH=$(PWD)/bin:$$PATH ; for cmd in $(COMMANDS) $(DEPCOMMANDS) ; do \
	  $(TESTCMD) ; \
	done; \
	if [ -n "$$miss" ]; then echo "You have to resolve dependencies and install missing commands."; exit 1; fi

initramfs: $(INITRAMFS) $(MOD_DEPS)
$(INITRAMFS): config.mk $(MOD_DEPS)
	@rm -rf /tmp/obn-initramfs; mkdir /tmp/obn-initramfs
	@rsync -rC $(PWD)/etc/initramfs-tools/ /tmp/obn-initramfs/
	@find /tmp/obn-initramfs/scripts/ /tmp/obn-initramfs/hooks/ -type f | xargs chmod +x
	@echo export ZABBIXHOST=$(zabbixserver) >$(PWD)/etc/obnova-embed.conf
	@echo export OBNOVANG_REV=\"$(SVNREVISION)\" >>$(PWD)/etc/obnova-embed.conf
	@echo "Generating initramfs"
	@export debug=$(DEBUG) commands="$(COMMANDS)" scommands="$(SCOMMANDS)" copyfiles="$(COPYFILES)" modules="$(MODULES)"; \
	 mkinitramfs -d /tmp/obn-initramfs/ -o $(INITRAMFS) $(KVERSION)
	@ls -lah $(KERNEL) $(INITRAMFS)	
show:
	@find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f -a '-!' -wholename '*/.svn/*' | xargs chmod +x
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
	echo ; \
	if [ -n "$(MOD_LOCALE)" ]; then echo "languages: $(LANGUAGES), charsets: $(CHARSETS)"; fi; \
	echo ;

kernel: $(KERNEL)
$(KERNEL):
	sudo cp /boot/vmlinuz-$(KVERSION) $(KERNEL)
	sudo chmod o+r $(KERNEL)
	
pxegrubimg:
	grub-mkimage --output=/tmp/core.img --prefix="(pxe)/boot/grub" $(GRUBMODULES)
	cat /usr/lib/grub/i386-pc/pxeboot.img /tmp/core.img >bin/grub2pxe.img

pxetest:
	$(QEMU) -tftp ./bin -boot n -bootp /grub2pxe.img
	
test: initramfs kernel
	$(QEMU) -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -net nic -net user -append 'root=/dev/ram rootdelay=1 obnovapath="$(serverip)::obnova" quiet loglevel=0'

debugtest: initramfs kernel extract
	$(QEMU) -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -net nic -net user -append 'root=/dev/ram rootdelay=1 obnovapath="$(serverip)::obnova"'

clean:
	@find ./ -name '*~' | xargs rm -f
	@rm -rf /tmp/obn-initramfs $(INITRAMFS) $(KERNEL)

distclean: clean
	@echo 'NOTCONFIGURED = 1' >config.mk

extract:
	rm -rf /tmp/obnovang
	mkdir -p /tmp/obnovang
	cd /tmp/obnovang; \
	gunzip -c -9  $(INITRAMFS) | cpio -i -d -H newc --no-absolute-filenames
 	
pxegrub:
	(echo 'set prefix=(pxe)/grub'; echo 'configfile (pxe)/grub/grub.cfg') >/tmp/menu.cfg
	grub-mkimage --format=i386-pc-pxe --prefix='(pxe)/grub' --output=bin/grub.pxe -c /tmp/menu.cfg $(GRUBMODULES)
	ls -lah bin/grub.pxe
	 