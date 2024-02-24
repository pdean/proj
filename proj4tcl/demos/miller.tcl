namespace path ::tcl::mathop
set r 6370997.0

package require proj
set P [proj create "+proj=mill +lon_0=90w +R=$r"]
set a [ list -100. 35.]
set b [proj fwd $P $a]
puts [format "%.2f %.2f" {*}$b]

package require mapproj
lassign [::mapproj::toMillerCylindrical -90 -100 35] e n
set e [* $r $e]
set n [* $r $n]
puts [format "%.2f %.2f" $e $n]
