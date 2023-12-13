SHELL := /bin/bash  # allow Bashisms in Makefile
PYTHON = $(shell which python python2 python3 | head -n 1)
export BITS ?= 32
all: agner src/PMCTestA /dev/MSRdrv
	$(PYTHON) $< run
%: %.cpp
	cd $(<D) && $(MAKE) $(@F)
test: tests
	$(PYTHON) $</branch.py
%.ko: %.c
	cd $(<D) && $(MAKE)
/dev/MSRdrv: src/driver/MSRdrv.ko .FORCE
	# from src/driver/install.sh
	rm -f $@
	mknod $@ c 249 0
	chmod 666 $@
	insmod -f $<
clean: src/Makefile src/driver/Makefile
	for file in $+; do $(MAKE) -C $$(dirname $$file) clean; done
.FORCE:
