P=proj.dll
OBJECTS=proj.o
CFLAGS=-g -Wall -O3 -std=gnu11 -fms-extensions -D_GNU_SOURCE -DUSE_TCL_STUBS 
LDLIBS=-Wl,-Bstatic  -ltclstub86 -lproj -Wl,-Bdynamic
LDFLAGS=-shared -fpic 
CC=gcc 

$(P): $(OBJECTS)
