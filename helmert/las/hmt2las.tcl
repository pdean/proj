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

    puts "-transform_affine $s,[- [* $t $rad2deg]],$x0,$y0
}

main
