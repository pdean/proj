#!/usr/bin/env tclsh
package require proj
set P [proj crs2crs "EPSG:4326" "+proj=utm +zone=32 +datum=WGS84"]
set norm [proj norm $P]
proj destroy $P
set P $norm
set a [list 12.0 55.]
set b [proj fwd $P $a]
puts [format "easting: %.3f, northing: %.3f" {*}$b]
set b [proj inv $P $b]
puts [format "longitude: %g, latitude: %g" {*}$b]
proj destroy $P
