#!/usr/bin/bash
#
txt2las64 -i mga.csv -rescale 0.001 0.001 0.001  -parse sxyz -o mga.las 
txt2las64 -i project.csv -rescale 0.001 0.001 0.001  -parse sxyz -o project.las
