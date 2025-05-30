SHELL := /bin/bash  # allow Bashisms in Makefile
OPTIMIZE ?=  # `make OPTIMIZE=-OO` for less verbose logging
PYTHON = $(shell which python3 python python2 | head -n 1) $(OPTIMIZE)
PYLIBDIR = $(shell $(PYTHON) -c "import sysconfig; \
 print(sysconfig.get_path('stdlib'))")
TIMESTAMP := $(shell date '+%Y%m%d%H%M%S')
PROJECT_MAKEFILES := $(wildcard */Makefile */*/Makefile)
# set IGNORESPACE= on command line to see difference in whitespace
# set IGNORESPACE=q to just get a list of files that are different
IGNORESPACE ?= w
# need to figure out a way to use SUBDIRS, not the cut-and-paste stuff below
SUBDIRS := DriverSrcLinux DriverSrcWin PMCTest TestScripts
ifeq ($(SHOWENV),)
	export TIMESTAMP
else
	export
endif
all: src/PMCTestA run
plot run list test_only: agner /dev/MSRdrv
	$(PYTHON) $< $@ 2>&1 | tee $<_$@.$(TIMESTAMP).log
	ln -sf $<_$@.$(TIMESTAMP).log $<_$@.log
	@echo see $<_$@.log for debugging
env:
ifeq ($(SHOWENV),)
	$(MAKE) SHOWENV=1 $@
else
	$@
endif
%: %.cpp
	$(MAKE) -C $(<D) $(@F)
tests: .FORCE
	$(PYTHON) $@/branch.py
test:
	$(MAKE) -C src $@
%.ko: %.c
	$(MAKE) -C $(<D)
clean: $(PROJECT_MAKEFILES)
	for file in $+; do $(MAKE) -C $$(dirname $$file) $@; done
	rm -f *.log
distclean: $(PROJECT_MAKEFILES)
	rm -f results.json
	for file in $+; do $(MAKE) -C $$(dirname $$file) $@; done
install: /dev/MSRdrv .FORCE
uninstall:
	$(MAKE) -C src/driver $@
/dev/MSRdrv:
	$(MAKE) -C src/driver $@
%.trace: %
	$(PYTHON) -m trace --trace --ignore-dir=$(PYLIBDIR) $<
%.diff: | $(HOME)/Downloads/testp/%
	diff -r$(IGNORESPACE) $*/ $|
TestScripts/%.diff: | $(HOME)/Downloads/testp/TestScripts/%
	diff $(@:.diff=) $|
TestScripts/%.update: | $(HOME)/Downloads/testp/TestScripts/%
	cp -f $| $(@:.update=)
DriverSrcLinux/%.diff: | $(HOME)/Downloads/testp/DriverSrcLinux/%
	diff $(@:.diff=) $|
DriverSrcLinux/%.update: | $(HOME)/Downloads/testp/DriverSrcLinux/%
	cp -f $| $(@:.update=)
DriverSrcWin/%.diff: | $(HOME)/Downloads/testp/DriverSrcWin/%
	diff $(@:.diff=) $|
DriverSrcWin/%.update: | $(HOME)/Downloads/testp/DriverSrcWin/%
	cp -f $| $(@:.update=)
PMCTest/%.diff: | $(HOME)/Downloads/testp/PMCTest/%
	diff $(@:.diff=) $|
PMCTest/%.update: | $(HOME)/Downloads/testp/PMCTest/%
	cp -f $| $(@:.update=)
.FORCE:
.PHONY: %.diff %.trace install clean distclean
