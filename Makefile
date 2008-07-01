
KERNEL=$(PWD)/bin/obnova.vmlinuz
INITRAMFS=$(PWD)/bin/obnova.initramfs

all: kernel initramfs

initramfs: $(INITRAMFS)
$(INITRAMFS):
	find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f | xargs chmod +x
	find $(PWD)/etc/initramfs-tools/scripts/ $(PWD)/etc/initramfs-tools/hooks/ -type f -a -name '*~' | xargs rm -f
	mkinitramfs -d $(PWD)/etc/initramfs-tools -o bin/obnova.initramfs

kernel: $(KERNEL)
$(KERNEL):
	cp /boot/vmlinuz-$(shell uname -r) bin/obnova.vmlinuz

test: initramfs kernel
	qemu -hda /dev/zero -kernel $(KERNEL) -initrd $(INITRAMFS) -append "root=/dev/ram rootdelay=1"

clean:
	rm -f $(INITRAMFS) $(KERNEL)

extract:
	rm -rf /tmp/obnovang
	mkdir -p /tmp/obnovang
	cd /tmp/obnovang; \
	gunzip -c -9  $(INITRAMFS) | cpio -i -d -H newc --no-absolute-filenames
 	