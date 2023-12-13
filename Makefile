SHELL := /bin/bash  # allow Bashisms in Makefile
PYTHON = $(shell which python python2 python3 | head -n 1)
HAVE_GETTID_IN_UNISTD_H ?= 1
ifeq ($(HAVE_GETTID_IN_UNISTD_H),1)
 export CXXFLAGS += -DHAVE_GETTID_IN_UNISTD_H=1
endif
all: agner src/PMCTestA /dev/MSRdrv
	$(PYTHON) $< run
%: %.cpp
	$(MAKE) -C $(<D) $(@F)
test: tests
	$(PYTHON) $</branch.py
%.ko: %.c
	$(MAKE) -C $(<D)
/dev/MSRdrv: src/driver/MSRdrv.ko .FORCE
	# from src/driver/install.sh
	sudo rm -f $@
	sudo mknod $@ c 249 0
	sudo chmod 666 $@
	sudo insmod -f $<
.FORCE:
