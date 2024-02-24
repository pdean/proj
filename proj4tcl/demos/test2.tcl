load ./proj.so

set S "+proj=pipeline  +zone=56 +south +ellps=GRS80"
append S " +step +inv +proj=utm"
append S " +step +proj=vgridshift +grids=./ausgeoid09.gtx"
append S " +step +proj=utm"
puts $S
set P [proj create $S] 
puts [proj fwd $P [list 502810 6964520 0]]

#load ./las.so

