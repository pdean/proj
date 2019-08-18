namespace path ::tcl::mathop

load ./proj.dll

set P [proj create "+proj=merc +ellps=clrk66 +lat_ts=33"]

set a [list -16.0 20.25]
puts $a

set b [proj fwd $P $a]
puts $b

set c [proj inv $P $b]
puts $c

proj destroy $P
puts ""


set P [proj crs2crs "EPSG:4326" "+proj=utm +zone=32 +datum=WGS84"]

set P [proj norm $P]

set a [list 12 55]
puts $a

set b [proj fwd $P $a]
puts $b

set c [proj inv $P $b]
puts $c

puts ""

set a [list 12 56]
puts $a

set b [proj fwd $P $a]
puts $b

set c [proj inv $P $b]
puts $c

proj destroy $P
puts ""

set pos [list 502810 6964520 0]
puts $pos
set mga56ag09 [proj create "+proj=utm +zone=56 +south +ellps=GRS80  +geoidgrids=./ausgeoid09.gtx"]
set result [proj inv $mga56ag09 $pos]
puts [format "%.5f %.5f %.3f" {*}$result]
# output -> -27.44279 153.02843 41.901
set result2 [proj fwd $mga56ag09 $result]
puts [format "%.5f %.5f %.3f" {*}$result2]

puts ""
set mga56 [proj create "+proj=utm +zone=56 +south +ellps=GRS80  "]
puts [proj fwd $mga56ag09 [proj inv $mga56 $pos]]
puts [proj fwd $mga56 [proj inv $mga56ag09 $pos]]


puts ""
set S "+proj=pipeline  +zone=56 +south +ellps=GRS80"
append S " +step +inv +proj=utm"
append S " +step +proj=vgridshift +grids=./ausgeoid09.gtx"
append S " +step +proj=utm"
puts $pos
puts $S
set P [proj create $S] 

puts [proj fwd $P $pos]

#package require trig
source trig.tcl
namespace import trig::*

puts ""
set lat  [dec -23.4012446019]
set lon  [dec 133.5307847844]
puts [dms $lat]
puts [dms $lon]

set gda94 [list  $lon $lat]

set G "+proj=hgridshift +grids=GDA94_GDA2020_conformal.gsb"
puts $G

set T [proj create $G]

lassign [proj fwd $T $gda94] lon lat
puts [dms $lat]
puts [dms $lon]
