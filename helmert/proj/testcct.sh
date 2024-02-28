#!/bin/sh
cct +proj=helmert +convention=coordinate_frame +x=3.095442701451804 +y=-2.376920234411955 +s=0.999600307072109 +theta=-0.09635984730596717 BulimbaCreekViaduct00.txt|unexpand -a  |cut -f 1,2,3|sed 's/ //g'
