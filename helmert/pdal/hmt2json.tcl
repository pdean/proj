package require json::write
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

#    ::json::write indented no
    set in [::json::write object-strings type readers.text filename #]
    set out [::json::write object-strings type writers.text filename #]
    set filter [::json::write object-strings type filters.projpipeline coord_op $S] 
    set json [::json::write array $in $filter $out]
    puts $json
}

main
