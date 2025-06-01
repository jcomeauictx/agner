SHELL := /bin/bash
ifeq ($(shell uname -m),x86_64)
 BITS ?= 64
else
 BITS ?= 32
endif
ifeq ($(USE_CPP),)
 EXECUTABLE := x
else
 EXECUTABLE := a.out
endif
ifneq ($(shell echo | cpp -dM | awk '$$2 == "__amd64__" {print $$3}'),)
 AMD64 := -DAMD64
endif
GPP := g++ -m$(BITS)
NASM := nasm -f elf$(BITS) $(AMD64)
ifeq ($(SHOWENV),)
	# export whatever is needed for subprocesses
else
	export
endif
# new default "all" is to bypass .sh files and just use Makefile
# (subsumes a32.sh a64.sh c32.sh c64.sh)
# `make old` to use Agner's shell scripts
all: $(EXECUTABLE)
	./$<
old:	a$(BITS).sh
	$(SHELL) $<
a$(BITS).o: PMCTestA.cpp
	$(GPP) -O2 -c -o$@ $<
b$(BITS).o: PMCTestB$(BITS).nasm
	$(NASM) -l $(@:.o=.lst) -o $@ $<
x: a$(BITS).o b$(BITS).o
	$(GPP) $+ -o$@ -lpthread -z noexecstack
a.out: a$(BITS).o PMCTestB.cpp
	$(GPP) -O2 $+ -lpthread
env:
ifeq ($(SHOWENV),)
	$(MAKE) SHOWENV=1 $@
else
	$@
endif
.PHONY: env all old
