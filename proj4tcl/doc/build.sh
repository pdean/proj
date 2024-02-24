#!/bin/sh

dtplite -o proj.n nroff proj.man 
dtplite -o proj.md markdown proj.man 
pandoc -f markdown -t pdf -o proj.pdf proj.md

