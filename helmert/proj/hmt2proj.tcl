#!/bin/env tclsh
namespace path {::tcl::mathop ::tcl::mathfunc}

proc main {} {
    set line [gets stdin]
    lassign [split $line ,] a b xm ym XM YM

    set x0 [expr {$XM-$a*$xm+$b*$ym}]
    set y0 [expr {$YM-$b*$xm-$a*$ym}]

    # scale rotation
    set s [hypot $a $b]
    set t [atan2 $b $a]
    set rad2deg [/ 45 [atan 1]]
    set rad2sec [* 3600 $rad2deg]

    # proj string
    set S +proj=helmert
    append S " +convention=coordinate_frame"
    append S " +x=$x0 +y=$y0"
    append S " +s=$s +theta=[- [* $t $rad2sec]]"

    puts $S
}

main
