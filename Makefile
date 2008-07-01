
KERNEL=$(PWD)/bin/obnovang.vmlinuz
INITRAMFS=$(PWD)/bin/obnovang.initramfs

all: kernel initramfs

initramfs: $(INITRAMFS)
$(INITRAMFS):
	find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f | xargs chmod +x
	find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f -a -name '*~' | xargs rm -f
	mkinitramfs -d $(PWD)/etc/initramfs-tools -o $(INITRAMFS)

kernel: $(KERNEL)
$(KERNEL):
	cp /boot/vmlinuz-$(shell uname -r) $(KERNEL)

test: initramfs kernel
	qemu -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -net nic -net user -append 'root=/dev/ram rootdelay=1 obnovapath="193.84.208.21::obnova" quiet loglevel=0'

debugtest: initramfs kernel extract
	qemu -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -net nic -net user -append 'root=/dev/ram rootdelay=1 obnovapath="193.84.208.21::obnova"'

clean:
	rm -f $(INITRAMFS) $(KERNEL)

extract:
	rm -rf /tmp/obnovang
	mkdir -p /tmp/obnovang
	cd /tmp/obnovang; \
	gunzip -c -9  $(INITRAMFS) | cpio -i -d -H newc --no-absolute-filenames
 	