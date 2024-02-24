#!/bin/sh
cut -d , -f 2,3,4 project.csv >project.txt
sed -i 's/,/ /g' project.txt
cct  +proj=helmert +convention=coordinate_frame +x=499358.446739681 +y=6796516.162735808 +s=0.9995887272118776 +theta=498.25810674319854 project.txt
