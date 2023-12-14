KERNELDIR := /lib/modules/`uname -r`/build
obj-m := MSRdrv.o
default: MSRdrv.ko
MSRdrv.ko: MSRdrv.c
	$(MAKE) -C $(KERNELDIR) M=`pwd` modules
clean:
	rm -f .MSRdrv.*
	rm -f -r .tmp_versions
	rm -f *~
	rm -f MSRdrv.ko
	rm -f MSRdrv.o
	rm -f MSRdrv.mod.*
	rm -f linux.mdl
	rm -f Module.symvers
	rm -f modules.order
distclean: clean
	rm -f MSRdrv.ko

/dev/MSRdrv: MSRdrv.ko .FORCE
	# from src/driver/install.sh
	$(MAKE) uninstall
	sudo mknod $@ c 249 0
	sudo chmod 666 $@
	sudo insmod -f $<
install: /dev/MSRdrv .FORCE
uninstall:
	sudo rm -f /dev/MSRdrv
	-sudo rmmod MSRdrv
.FORCE:
