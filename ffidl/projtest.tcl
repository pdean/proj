package provide proj 0.1

package require Ffidl 
package require Ffidlrt 

namespace path [list ::tcl::mathop ::tcl::mathfunc]

switch $tcl_platform(platform) {
    unix    {set PROJLIB libproj.so}
    windows {set PROJLIB proj_9_1.dll}
}

::ffidl::typedef PJ pointer
::ffidl::typedef XYZT double double double double 

# raw
::ffidl::callout _proj_create_crs_to_crs \
    {pointer pointer-utf8 pointer-utf8 pointer} PJ \
    [::ffidl::symbol $PROJLIB proj_create_crs_to_crs]

::ffidl::callout _proj_trans \
    {PJ int XYZT} XYZT \
    [::ffidl::symbol $PROJLIB proj_trans]

# cooked
proc proj_create_crs_to_crs {src tgt} {
    set NULL [::ffidl::info NULL]
    _proj_create_crs_to_crs $NULL $src $tgt $NULL
}

proc proj_trans {pj dir v} {
    set n [llength $v]
    if {$n < 2} {error "1D vector!"}
    if {$n > 4} {error "${n}D vector!"}
    incr n -1
    set v [lreplace [lrepeat 4 [double 0]] 0 $n {*}$v]
    set v [binary format d4 $v]
    set v [_proj_trans $pj [int $dir] $v]
    binary scan $v d4 v
    lrange $v 0 $n 
}

proc proj_fwd {pj v} {
    proj_trans $pj  1 $v
}

proc proj_inv {pj v} {
    proj_trans $pj  -1 $v
}

proc deg {x} {
    lassign $x d m s
    if {$d < 0} {
        set m [- [abs $m]]
        set s [- [abs $s]]
    }
    + $d [/ [+ $m [/ $s 60.0]] 60.0]
}

proc dms {x} {
    set neg [< $x 0.0]
    set d [abs $x]
    set deg [floor $d]
    set m [* [- $d $deg] 60.]
    set min [floor $m]
    set sec [* [- $m $min] 60.]
    if {$neg} { set deg [- $deg] }
    list $deg $min $sec
}

proc dmsstr {d} {
    format "%.0fd %.0f' %.5f\"" {*}$d
}

proc fmt3 {x} {
    format "%.3f" $x
}



# test raw

set FWD [int 1]
set INV [int -1]
set NULL [::ffidl::info NULL]

proc tovec {xyzt} {
    binary format [::ffidl::info format XYZT] {*}$xyzt
}

proc fromvec {vec} {
    binary scan $vec [::ffidl::info format XYZT] x y z t
    list $x $y $z $t
}

puts "test raw"
puts ""

set P [_proj_create_crs_to_crs $NULL epsg:4283  epsg:7844 $NULL ]
set lat "-23 40 12.446019"
set lon "133 53  7.847844"
puts "$lat   $lon"

set x [list [deg $lat] [deg $lon] 0.0 0.0] 
puts $x
set x [fromvec [_proj_trans $P $FWD [tovec $x]]]
puts $x
lassign $x lat lon
puts "[dms $lat]   [dms $lon]"

puts ""

set P [_proj_create_crs_to_crs $NULL epsg:7844  epsg:7855 $NULL]
set x [list [deg "-37 39 10.156111"] [deg "143 55 35.383889"] 0 0 ]
puts $x
set x [fromvec [_proj_trans $P $FWD [tovec $x]]]
puts $x
set x [fromvec [_proj_trans $P $INV [tovec $x]]]
puts $x

puts ""
set x [list [deg "-37 57 3.720296"] [deg "144 25 29.524415"] 0 0 ]
puts $x
set x [fromvec [_proj_trans $P $FWD [tovec $x]]]
puts $x
set x [fromvec [_proj_trans $P $INV [tovec $x]]]
puts $x

puts ""
puts "test cooked"
puts ""

set P [proj_create_crs_to_crs  epsg:7844  epsg:7855 ]
set x {"-37 57 3.72030" "144 25 29.52440"}
puts [lmap d $x {dmsstr $d}]
set x [lmap d $x {deg $d}]
set x [proj_fwd $P $x]
puts [lmap d $x {fmt3 $d}]
set x [proj_inv $P $x]
set x [lmap d $x {dms $d}]
puts [lmap d $x {dmsstr $d}]

puts ""

set mga2gda [proj_create_crs_to_crs epsg:7856 epsg:7844]
set gda2ahd [proj_create_crs_to_crs epsg:7843 epsg:9463]
set x {502810 6964520 0}
puts [lmap p $x {fmt3 $p}]
set x [proj_fwd $mga2gda $x]
puts $x
set x [proj_fwd $gda2ahd $x]
puts $x
set x [proj_inv $mga2gda $x]
puts [lmap p $x {fmt3 $p}]

puts ""

set mga2gda [proj_create_crs_to_crs epsg:7856 epsg:7844]
set gda2ahd [proj_create_crs_to_crs epsg:7843 epsg:9463]
set x {502810 6964520 0}
puts [lmap p $x {fmt3 $p}]
set x [proj_fwd $mga2gda $x]
puts $x
set x [proj_inv $gda2ahd $x]
puts $x
set x [proj_inv $mga2gda $x]
puts [lmap p $x {fmt3 $p}]



puts ""

set mga2gda [proj_create_crs_to_crs epsg:28356 epsg:4283]
set gda2ahd [proj_create_crs_to_crs epsg:4939 epsg:9464]
set x {502810 6964520 0}
puts [lmap p $x {fmt3 $p}]
set x [proj_fwd $mga2gda $x]
puts $x
set x [proj_fwd $gda2ahd $x]
puts $x
set x [proj_inv $mga2gda $x]
puts [lmap p $x {fmt3 $p}]


puts ""

set mga2gda [proj_create_crs_to_crs epsg:28356 epsg:4283]
set gda2ahd [proj_create_crs_to_crs epsg:4939 epsg:9464]
set x {502810 6964520 0}
puts [lmap p $x {fmt3 $p}]
set x [proj_fwd $mga2gda $x]
puts $x
set x [proj_inv $gda2ahd $x]
puts $x
set x [proj_inv $mga2gda $x]
puts [lmap p $x {fmt3 $p}]


puts ""


set mga2gda [proj_create_crs_to_crs epsg:7856 epsg:7844]
set gda2ahd [proj_create_crs_to_crs epsg:7843 epsg:9463]
set x {502810 6964520 50}
puts [lmap p $x {fmt3 $p}]
set x [proj_inv $mga2gda [proj_fwd $gda2ahd [ proj_fwd $mga2gda $x]]]
puts [lmap p $x {fmt3 $p}]

puts ""


set mga2gda [proj_create_crs_to_crs epsg:28356 epsg:4283]
set gda2ahd [proj_create_crs_to_crs epsg:4939 epsg:9464]
set x {502810 6964520 50}
puts [lmap p $x {fmt3 $p}]
set x [proj_inv $mga2gda [proj_fwd $gda2ahd [ proj_fwd $mga2gda $x]]]
puts [lmap p $x {fmt3 $p}]

