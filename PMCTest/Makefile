SHELL := /bin/bash
ifeq ($(shell uname -m),x86_64)
	BITS ?= 64
else
	BITS ?= 32
endif
GPP := g++ -O2 -m$(BITS)
all:	a$(BITS).sh
	$(SHELL) $<
a$(BITS).o: PMCTestA.cpp
	$(GPP) -c -o$@ $<
a.out: a$(BITS).o PMCTestB.cpp
	$(GPP) $+ -lpthread
