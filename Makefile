SHELL := /bin/bash  # allow Bashisms in Makefile
PYTHON = $(shell which python python2 python3 | head -n 1)
all: agner
	$(PYTHON) $<
