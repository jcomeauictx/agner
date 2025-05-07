SHELL := /bin/bash  # allow Bashisms in Makefile
OPTIMIZE ?=  # `make OPTIMIZE=-OO` for less verbose logging
PYTHON = $(shell which python python2 python3 | head -n 1) $(OPTIMIZE)
PYLIBDIR = $(shell $(PYTHON) -c 'import os; print os.path.dirname(os.__file__)')
TIMESTAMP := $(shell date '+%Y%m%d%H%M%S')
all: src/PMCTestA run
plot run list test_only: agner /dev/MSRdrv
	$(PYTHON) $< $@ 2>&1 | tee $<_$@.$(TIMESTAMP).log
	ln -sf $<_$@.$(TIMESTAMP).log $<_$@.log
	@echo see $<_$@.log for debugging
env:
	$@
%: %.cpp
	$(MAKE) -C $(<D) $(@F)
tests: .FORCE
	$(PYTHON) $@/branch.py
test:
	$(MAKE) -C src $@
%.ko: %.c
	$(MAKE) -C $(<D)
clean: src/Makefile src/driver/Makefile
	for file in $+; do $(MAKE) -C $$(dirname $$file) $@; done
	rm -f *.log
distclean: src/Makefile src/driver/Makefile
	rm -f results.json
	for file in $+; do $(MAKE) -C $$(dirname $$file) $@; done
install: /dev/MSRdrv .FORCE
uninstall:
	$(MAKE) -C src/driver $@
/dev/MSRdrv:
	$(MAKE) -C src/driver $@
%.trace: %
	$(PYTHON) -m trace --trace --ignore-dir=$(PYLIBDIR) $<
.FORCE:
