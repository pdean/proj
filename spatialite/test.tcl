namespace path {::tcl::mathop ::tcl::mathfunc}

source kmlout.tcl

package require tdbc::sqlite3
tdbc::sqlite3::connection create db :memory:
[db getDBhandle] enable_load_extension 1
db allrows {select load_extension('mod_spatialite')}
db allrows {SELECT InitSpatialMetaData()}

proc maketransform {from to} {
    set sql {
        select x(p.geom),y(p.geom)
        from
        (select
        transform(makepoint(casttodouble(:x),casttodouble(:y),$from),$to)
        as geom) p
    }
    return [db prepare [subst $sql]]
}

proc transform {t x y} {
    lindex [$t allrows -as lists] 0
}

proc fmt {x} {
    return [format %.1f $x]
}

proc tstr {time} {
    set secs  $time
    set fsecs [string trimleft [format %.2f [- $secs [int $secs]]] 0]
    set secs [format %.2f $secs]
    set now [format %s%s [clock format  [int $secs] -format %T -gmt 1 ] $fsecs ]
}

proc kmlstyle {point} {
    global t

    lassign $point x y z id
    lassign  [transform $t $x $y] lon lat 
    set style Info
    set desc "$id<br>[fmt $x]<br>[fmt $y]<br>[fmt $z]"
    return [list $id $desc $style $lon $lat $z]
}

proc run {csv} {
    global t
    set t [maketransform 7856 4326]
    puts $t

    set href http://maps.google.com/mapfiles/kml/shapes/info.png
    set styles [subst {{Info $href ff00ff00}}]
    set in [open $csv r]
    while {[gets $in line] >= 0} {
        lappend points [split $line ,]
    }
    close $in

    set kml [file root $csv]_4326.kml
    kmlout [lmap p $points {kmlstyle $p}] $styles $kml
}

set csv 202588_Sample_32properties.txt
run $csv
