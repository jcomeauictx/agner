SHELL := /bin/bash  # allow Bashisms in Makefile
PYTHON = $(shell which python python2 python3 | head -n 1)
PYLIBDIR = $(shell $(PYTHON) -c 'import os; print os.path.dirname(os.__file__)')
all: src/PMCTestA run
plot run list test_only: agner /dev/MSRdrv
	$(PYTHON) $< $@
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
