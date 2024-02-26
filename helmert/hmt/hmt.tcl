#!/usr/bin/env tclsh

namespace path { ::tcl::mathop ::tcl::mathfunc}

proc readpts {file} {
    set in [open $file r]
    set xp [list]
    set yp [list]
    while {[gets $in line] >= 0} {
        lassign [split $line ,] p x y z
        lappend xp $x
        lappend yp $y
    }
    close $in
    return [list $xp $yp]
}

proc main {} {
    if {[llength $::argv] != 2} {
        puts "usage: hmt frompts topts"
        exit 1
    }
    lassign $::argv fromfile tofile

    lassign [readpts $fromfile] xp yp
    lassign [readpts $tofile] XP YP

    # calc sums
    lassign {0 0.0 0.0 0.0 0.0} n xs ys XS YS
    foreach x $xp y $yp X $XP Y $YP {
        incr n
        set xs [+ $xs $x]
        set ys [+ $ys $y]
        set XS [+ $XS $X]
        set YS [+ $YS $Y]
    }

    # calc means
    set xm [/ $xs $n]
    set ym [/ $ys $n]
    set XM [/ $XS $n]
    set YM [/ $YS $n]

    # calc products
    lassign {0.0 0.0 0.0 0.0 0.0 0.0} xx yy xX yY xY yX
    foreach x $xp y $yp X $XP Y $YP {
        set xb [- $x $xm]
        set yb [- $y $ym]
        set XB [- $X $XM]
        set YB [- $Y $YM]
        set xx [+ $xx [* $xb $xb]]
        set yy [+ $yy [* $yb $yb]]
        set xX [+ $xX [* $xb $XB]]
        set yY [+ $yY [* $yb $YB]]
        set yX [+ $yX [* $yb $XB]]
        set xY [+ $xY [* $xb $YB]]
    }

    # helmert parameters
    set a [/ [+ $xX $yY] [+ $xx $yy]]
    set b [/ [- $xY $yX] [+ $xx $yy]]
    set x0 [expr {$XM-$a*$xm+$b*$ym}]
    set y0 [expr {$YM-$b*$xm-$a*$ym}]

    # check residuals
    foreach x $xp y $yp X $XP Y $YP {
        set XN [expr {$x0+$a*$x-$b*$y}]
        set YN [expr {$y0+$b*$x+$a*$y}]
        set DX [- $XN $X]
        set DY [- $YN $Y]
        puts [format "%12.4f %14.4f %6.4f %6.4f" $XN $YN $DX $DY]
    }

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
    puts ""

    # hmt
    puts "$a,$b,$xm,$ym,$XM,$YM"
    puts ""


}

main
