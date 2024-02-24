#!/bin/sh
gcc -shared -fpic -g -Wall -O2 \
    -DUSE_TCL_STUBS   \
    -I/c/tcl/include -I/c/OSGeo4W/include \
    ../generic/proj.c -o proj.dll \
    -L/c/tcl/lib -ltclstub86 \
    -L/c/OSGeo4W/bin -lproj_9_3
