SHELL := /bin/bash  # allow Bashisms in Makefile
PYTHON = $(shell which python python2 python3 | head -n 1)
HAVE_GETTID_IN_UNISTD_H ?= 1
ifeq ($(HAVE_GETTID_IN_UNISTD_H),1)
 CXXFLAGS += -DHAVE_GETTID_IN_UNISTD_H=1
endif
CXXFLAGS += -z noexecstack
ifeq ($(shell uname -m),x86_64)
 BITS ?= 64
else
 BITS ?= 32
endif
export BITS CXXFLAGS
all: src/PMCTestA /dev/MSRdrv run
run: agner
	$(PYTHON) $< run
plot: agner
	$(PYTHON) $< plot
env:
	$@
%: %.cpp
	$(MAKE) -C $(<D) $(@F)
test: tests
	$(PYTHON) $</branch.py
%.ko: %.c
	$(MAKE) -C $(<D)
/dev/MSRdrv: src/driver/MSRdrv.ko .FORCE
	# from src/driver/install.sh
	sudo rmmod -f $(@F)
	sudo rm -f $@
	sudo mknod $@ c 249 0
	sudo chmod 666 $@
	sudo insmod -f $<
clean: src/Makefile src/driver/Makefile
	for file in $+; do $(MAKE) -C $$(dirname $$file) clean; done
.FORCE:
