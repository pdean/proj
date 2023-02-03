
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
