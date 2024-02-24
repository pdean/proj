#!/usr/bin/env tclsh
package require proj

set zone 56
set pos [list 502810 6964520 0]
puts $pos

puts "mga to geographic gda94"

set cs [proj crs2crs EPSG:283$zone EPSG:4283]
set result [proj fwd $cs $pos]
puts [format "%.9f %.9f %.3f" {*}$result]
set result2 [proj inv $cs $result]
puts [format "%.5f %.5f %.3f\n" {*}$result2]

puts "mga to geographic gda2020 same"

set cs [proj crs2crs EPSG:78$zone EPSG:7844]
set cs [proj norm $cs]
set result [proj fwd $cs $pos]
puts [format "%.9f %.9f %.3f" {*}$result]
set result2 [proj inv $cs $result]
puts [format "%.5f %.5f %.3f\n" {*}$result2]

puts "mga to mga gda94 to gda2020 helmert?"

set cs [proj crs2crs EPSG:283$zone EPSG:78$zone]
set result [proj fwd $cs $pos]
puts [format "%.3f %.3f %.3f" {*}$result]

puts ""
puts "mga to mga gda94 to gda2020 gridshift"

set S    " +proj=pipeline +zone=$zone +south +ellps=GRS80"
append S " +step +inv +proj=utm"
append S " +step +proj=hgridshift +grids=au_icsm_GDA94_GDA2020_conformal.tif"
append S " +step +proj=utm"
set cs [proj create $S]
set result [proj fwd $cs $pos]
puts [format "%.3f %.3f %.3f" {*}$result]

puts ""
puts "mga eht to ahd ausgeoid09 using 3steps"

set mga2gda [proj crs2crs epsg:283$zone epsg:4283]
set gda2ahd [proj crs2crs epsg:4939 epsg:9464]
set result [proj inv $mga2gda [proj fwd $gda2ahd [proj fwd $mga2gda $pos]]]
puts [format "%.3f %.3f %.3f" {*}$result]

puts ""
puts "mga eht to ahd ausgeoid2020 using 3steps"

set mga2gda [proj crs2crs epsg:78$zone epsg:7844]
set gda2ahd [proj crs2crs epsg:7843 epsg:9463]
set result [proj inv $mga2gda [proj fwd $gda2ahd [proj fwd $mga2gda $pos]]]
puts [format "%.3f %.3f %.3f" {*}$result]

puts ""
puts "mga eht to ahd ausgeoid09 using 1step"

set S    " +proj=pipeline  +zone=$zone +south +ellps=GRS80"
append S " +step +inv +proj=utm"
append S " +step +proj=vgridshift +grids=au_ga_AUSGeoid09_V1.01.tif"
append S " +step +proj=utm"
set cs [proj create $S]
set result [proj fwd $cs $pos]
puts [format "%.3f %.3f %.3f" {*}$result]

puts ""
puts "mga eht to ahd ausgeoid2020 using 1step"

set S    " +proj=pipeline  +zone=$zone +south +ellps=GRS80"
append S " +step +inv +proj=utm"
append S " +step +proj=vgridshift +grids=au_ga_AUSGeoid2020_20180201.tif"
append S " +step +proj=utm"
set cs [proj create $S]
set result [proj fwd $cs $pos]
puts [format "%.3f %.3f %.3f" {*}$result]
