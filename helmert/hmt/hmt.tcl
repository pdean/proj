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
    set a1 [/ [+ $xX $yY] [+ $xx $yy]]
    set b1 [/ [- $xY $yX] [+ $xx $yy]]
    set a0 [expr {$XM-$a1*$xm+$b1*$ym}]
    set b0 [expr {$YM-$b1*$xm-$a1*$ym}]

    # check residuals
    foreach x $xp y $yp X $XP Y $YP {
        set XN [expr {$a0+$a1*$x-$b1*$y}]
        set YN [expr {$b0+$b1*$x+$a1*$y}]
        set DX [- $XN $X]
        set DY [- $YN $Y]
        puts [format "%12.3f %14.3f %6.3f %6.3f" $XN $YN $DX $DY]
    }

    # scale rotation
    set s [hypot $a1 $b1]
    set t [atan2 $b1 $a1]
    set rad2deg [/ 45 [atan 1]]
    set rad2sec [* 3600 $rad2deg]

    # proj string
    set S +proj=helmert
    append S " +convention=coordinate_frame"
    append S " +x=$a0 +y=$b0"
    append S " +s=$s +theta=[- [* $t $rad2sec]]"
    puts $S
    puts ""

    # hmt
    puts "$a1,$b1,$xm,$ym,$XM,$YM"
    puts ""

    # las2las
    puts "-transform_affine $s,[- [* $t $rad2deg]],$a0,$b0 \
          -reoffset [format "%.0f %.0f %.0f" $XM $YM 0.0]"



}

main
