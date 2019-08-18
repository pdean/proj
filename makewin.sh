#gcc -shared -fpic -g -Wall -O2 -DUSE_TCL_STUBS  proj.c -o proj.dll -ltclstub86 -lproj
gcc -shared -fpic -g -Wall -O2 -I/c/tcl/include -DUSE_TCL_STUBS   proj.c -o proj.dll  -L/c/tcl/lib -ltclstub86 -L/c/OSGeo4W64/apps/proj-dev/bin -lproj_6_1
