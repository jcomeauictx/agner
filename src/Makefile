DRIVER_SRC := driver
HAVE_GETTID_IN_UNISTD_H ?= 1
ifeq ($(HAVE_GETTID_IN_UNISTD_H),1)
 CXXFLAGS += -DHAVE_GETTID_IN_UNISTD_H=1
endif
CXXFLAGS += -z noexecstack
CXXFLAGS += -m$(BITS)
ifeq ($(shell uname -m),x86_64)
 BITS ?= 64
else
 BITS ?= 32
endif
export BITS CXXFLAGS
INCLUDES += -I$(DRIVER_SRC)
ifeq ($(BITS),32)
 INCLUDES += -I/usr/include/i386-linux-gnu
else
 INCLUDES += -I/usr/include/x86_64-linux-gnu
endif
all: out/a$(BITS).o PMCTestA
out:
	mkdir -p $@
out/a$(BITS).o: PMCTestA.cpp *.h $(DRIVER_SRC)/*.h | out
	g++ -O2 -c $(CXXFLAGS) -o $@ $< $(INCLUDES)
out/b$(BITS).o: PMCTestB64.nasm out/test.inc
	nasm -f elf$(BITS) -l out/b$(BITS).lst -l $(@D) -o $@ \
	 -D REPETITIONS=$(REPETITIONS) -D NUM_THREADS=$(NUM_THREADS) $<
%: %.cpp
	g++ -O2 -c $(CXXFLAGS) -o $@ $< $(INCLUDES)
clean:
	rm -f out/*
distclean: clean
	rm -f PMCTestA
out/test: out/a$(BITS).o out/b$(BITS).o
	g++ -z noexecstack -o $@ $+ -lpthread
test: out/test
	$<
