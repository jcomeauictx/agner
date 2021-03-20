DRIVER_SRC := driver
INCLUDES += -I/usr/include/i386-linux-gnu
INCLUDES += -I$(DRIVER_SRC)
BITS ?= 32
out/a$(BITS).o: PMCTestA.cpp *.h $(DRIVER_SRC)/*.h
	mkdir -p out
	g++ -O2 -c -m$(BITS) -o out/a$(BITS).o PMCTestA.cpp $(INCLUDES)
