package require json::write

proc main {} {
    ::json::write indented no
    set in [::json::write object-strings type readers.text filename project.txt]
    set out [::json::write object-strings type writers.text filename  mga.txt]
    set proj "+proj=helmert +convention=coordinate_frame +x=499358.446739681 +y=6796516.162735808 +s=0.9995887272118776 +theta=498.25810674319854"
    set filter [::json::write object-strings type filters.projpipeline coord_op $proj] 
    
    set json [::json::write array $in $filter $out]
    puts $json

}

main
