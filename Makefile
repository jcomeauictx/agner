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
all: src/PMCTestA run
plot run list test_only: agner /dev/MSRdrv
	$(PYTHON) $< $@
env:
	$@
%: %.cpp
	$(MAKE) -C $(<D) $(@F)
test: tests
	$(PYTHON) $</branch.py
%.ko: %.c
	$(MAKE) -C $(<D)
clean: src/Makefile src/driver/Makefile
	for file in $+; do $(MAKE) -C $$(dirname $$file) $@; done
distclean: src/Makefile src/driver/Makefile
	rm -f results.json
	for file in $+; do $(MAKE) -C $$(dirname $$file) $@; done
install: /dev/MSRdrv .FORCE
uninstall:
	$(MAKE) -C src/driver $@
/dev/MSRdrv:
	$(MAKE) -C src/driver $@
.FORCE:
