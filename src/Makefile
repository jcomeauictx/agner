DRIVER_SRC := driver
BITS ?= 32
CXXFLAGS ?= -z noexecstack
CXXFLAGS += -m$(BITS)
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
%: %.cpp
	g++ -O2 -c $(CXXFLAGS) -o $@ $< $(INCLUDES)
clean:
	rm -f out/*
distclean: clean
	rm -f PMCTestA
