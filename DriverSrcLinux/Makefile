# Make MSR driver for Linux
# Last modified: 2020-08-17 Agner Fog
# See https://www.kernel.org/doc/html/latest/kbuild/modules.html


KERNELDIR := /lib/modules/`uname -r`/build
obj-m := MSRdrv.o
PWD := $(shell pwd)

all default: /dev/MSRdrv install
MSRdrv.ko: MSRdrv.c MSRdrvL.h
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
    
#$(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) modules    

clean:
	rm -f .MSRdrv.*
	rm -f -r .tmp_versions
	rm -f *~
	rm -f MSRdrv.o
	rm -f MSRdrv.mod.*
	rm -f linux.mdl
	rm -f Modules.symvers
distclean: clean
	rm -f MSRdrv.ko
    
/dev/MSRdrv: MSRdrv.ko .FORCE
	# from src/driver/install.sh
	$(MAKE) uninstall
	sudo mknod $@ c 249 0
	sudo chmod 666 $@
	sudo insmod -f $<
install: /dev/MSRdrv .FORCE
	true  # keeps GNU make from `cat install.sh >install; chmod +x install`
uninstall:
	sudo rm -f /dev/MSRdrv
	-sudo rmmod MSRdrv
.FORCE:
