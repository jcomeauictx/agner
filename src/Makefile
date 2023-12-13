DRIVER_SRC := driver
INCLUDES += -I/usr/include/i386-linux-gnu
INCLUDES += -I$(DRIVER_SRC)
BITS ?= 32
CXXFLAGS += -m$(BITS)
all: out/a$(BITS).o PMCTestA
out/a$(BITS).o: PMCTestA.cpp *.h $(DRIVER_SRC)/*.h
	mkdir -p out
	g++ -O2 -c $(CXXFLAGS) -o $@ PMCTestA.cpp $(INCLUDES)
%: %.cpp
	g++ -O2 -c $(CXXFLAGS) -o $@ $< $(INCLUDES)
