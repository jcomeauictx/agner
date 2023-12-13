DRIVER_SRC := driver
BITS ?= 32
CXXFLAGS += -m$(BITS)
INCLUDES += -I$(DRIVER_SRC)
ifeq ($(BITS),32)
 INCLUDES += -I/usr/include/i386-linux-gnu
else
 INCLUDES += -I/usr/include/x86_64-linux-gnu
endif
all: out/a$(BITS).o PMCTestA
out/a$(BITS).o: PMCTestA.cpp *.h $(DRIVER_SRC)/*.h
	mkdir -p out
	g++ -O2 -c $(CXXFLAGS) -o $@ PMCTestA.cpp $(INCLUDES)
%: %.cpp
	g++ -O2 -c $(CXXFLAGS) -o $@ $< $(INCLUDES)
