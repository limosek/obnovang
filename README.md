# This is Obnovang project used to cleanup lab PCs. 

This software is used to cleanup PCs in laboratory. If you have PCs with same HW and SW and you do not want to waste your time by manual cleanup, this software can help you.
Instead of imaging tools, Obnovang is using rsync algorithm which copy only changed and missing files so it is much more quicker to cleanup entire lab.

# How it works

ObnovaNG software using initramfs tools for build image ObnovaNG,  PXElinux for boot,  TFTP,  DHCP and  Rsync server 
But this project is prepared for refresh or cleanup computers from local media (usb disk, cdrom, ...) ObnovaNG process

1) bootloader get IP from DHCP and link on TFTP
2) get image pxelinuxu from TFTP and install into memory
3) pxelinux get IP from DHCP and get bootconfig from TFTP
4a) loocalboot
4b) ObnovaNG
5) ObnovaNG get IP from DHCP 
6) ObnovaNG get link on config file for ObnovaNG
7) start ObnovaNG with config file 

# How to use

## Image creation
To create kernel and initramfs, needed to boot, please run
```
$ ./configure
$ make
```

For more options, see
```
$ ./configure --help
```
Result will be in directory bin/ . You can test boot by
```
$ make test
```
or extract contents of initramfs to /tmp/obnova/
```
$ make extract
```

## Instalation and configuration

### Rsync server

See rsync manual. 

### TFTP

Put generated vmlinuz and initramfs into TFTP server. Download PXELinux and download it there too. See TFTP and PXELinux manual.
```
Example pxelinux config:
	LABEL ObnovaNG
		kernel obnovang.vmlinuz
		append root=/dev/ram ro init=/bin/obnovang obnovapath="<rsync_server_ip>::obnova" ramdisk_size=32000 loglevel=0 unattended initrd=obnovang.initramfs
```
### DHCP

Point your DHCP server to boot PCs from network (dhcpd.conf). See DHCP server manual.
```
subnet x.x.x.x netmask y.y.y.y {
	allow booting;
        allow bootp;

        next-server tftp_server;
        filename "/pxelinux/pxelinux.0";
}
```
### PCs

Enable booting from network in BIOS.

# Team

If you have any question or recommendation for ObnovaNG, feel free to use github resources.

## Credits

Lukáš MACURA, Tomáš Králik, Pavel Běhal and others


