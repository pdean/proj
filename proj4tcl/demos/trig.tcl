# trig.tcl

package require Tcl 8.2
package provide trig 1.0

namespace eval ::trig {
  variable Pi [expr {acos(-1)}]
  variable 2Pi [expr {2*acos(-1)}]
  variable Deg2Rad [expr {$Pi/180}]
  variable Rad2Deg [expr {180/$Pi}]
  namespace export rad deg 
  namespace export dec dms 
  namespace export ang posang
  namespace export polar rect
}

proc ::trig::rad {d} {
   variable Deg2Rad
   return [expr {$d*$Deg2Rad}]
}

proc ::trig::deg {r} {
   variable Rad2Deg
  return [expr {$r*$Rad2Deg}]
}
   
proc ::trig::dms {d} {
  set si [expr {$d<0?-1:1}]
  set d [expr {abs($d)}]
  set m [expr {($d-floor($d))*60}]
  set s  [expr {($m-floor($m))*60}]
  set dms [expr { $si*(floor($d)+(floor($m)+$s/100)/100)}]
  return $dms
}

proc ::trig::dec {d} {
  set si [expr {$d<0?-1:1}]
  set d [expr {abs($d)}]
  set dmmss [expr {floor($d*10000+0.5)}]
  set fs [expr {$d*10000-$dmmss}]
  set d [expr {floor($dmmss/10000)}]
  set dmmss [expr {$dmmss-10000*$d}]
  set m [expr {floor($dmmss/100)}]
  set s [expr {$dmmss-100*$m}]
  set dec [expr { $si*($d+($m+($s+$fs)/60)/60)}]
  return $dec
}

proc trig::posang {x} {
  variable 2Pi

  return [expr \
   {$x-floor($x/$2Pi)*$2Pi}]
}

proc trig::ang {x} {
  variable Pi
  variable 2Pi

  return [expr {fmod($x+$Pi,$2Pi)-$Pi}]
}



proc trig::polar {x y} {
    set r [expr {hypot($y,$x)}]
    set t [expr {atan2($y,$x)}]
    return [list $r $t]
}

proc trig::rect {r t} {
    set x [expr {$r*cos($t)}]
    set y [expr {$r*sin($t)}]
    return [list $x $y]
}


