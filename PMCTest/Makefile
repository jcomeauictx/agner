SHELL := /bin/bash
ifeq ($(shell uname -m),x86_64)
	BITS ?= 64
else
	BITS ?= 32
endif
all:	a$(BITS).sh
	$(SHELL) $<
