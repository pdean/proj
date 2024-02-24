
[//000000001]: # (proj \- tcl math)
[//000000002]: # (Generated from file 'proj\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2009\-2024 Peter Dean)
[//000000004]: # (proj\(n\) 1\.0\.0 proj "tcl math")

# NAME

proj \- Projection calculations for tcl

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Commands](#section2)

  - [Examples](#section3)

  - [References](#section4)

  - [Bugs, Todo, etc](#section5)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require proj  

[__proj__ __create__ *projstring*](#1)  
[__proj__ __cr2crs__ *projstring* *projstring*](#2)  
[__proj__ __norm__ *handle*](#3)  
[__proj__ __destroy__ *handle*](#4)  
[__proj__ __fwd__ *handle* *list*](#5)  
[__proj__ __inv__ *handle* *list*](#6)  

# <a name='description'></a>DESCRIPTION

__proj__ provides minimal Tcl interface to proj projection library \(which
must already be installed\)\.

# <a name='section2'></a>Commands

  - <a name='1'></a>__proj__ __create__ *projstring*

    returns handle

  - <a name='2'></a>__proj__ __cr2crs__ *projstring* *projstring*

    returns handle

  - <a name='3'></a>__proj__ __norm__ *handle*

    returns a new handle whose axis order is the one expected for visualization
    purposes\.

  - <a name='4'></a>__proj__ __destroy__ *handle*

    deallocate handle

  - <a name='5'></a>__proj__ __fwd__ *handle* *list*

    returns tranformed point

  - <a name='6'></a>__proj__ __inv__ *handle* *list*

    returns tranformed point using inverse transformation

# <a name='section3'></a>Examples

    package require proj
    set P [proj crs2crs "EPSG:4326" "+proj=utm +zone=32 +datum=WGS84"]
    set norm [proj norm $P]
    proj destroy $P
    set P $norm
    set a [list 12.0 55.]
    set b [proj fwd $P $a]
    puts [format "easting: %.3f, northing: %.3f" {*}$b]
    set b [proj inv $P $b]
    puts [format "longitude: %g, latitude: %g" {*}$b]
    proj destroy $P
    # end

    produces result
    easting: 691875.632, northing: 6098907.825
    longitude: 12, latitude: 55
    (corresponds to first example in quickstart.html)

# <a name='section4'></a>References

  1. PROJ [https://proj\.org](https://proj\.org)

  1. Quick start for projstrings
     [https://proj\.org/usage/quickstart\.html](https://proj\.org/usage/quickstart\.html)

  1. Projections
     [https://proj\.org/operations/projections/index\.html](https://proj\.org/operations/projections/index\.html)

  1. Quick start for C API usage
     [https://proj\.org/development/quickstart\.html](https://proj\.org/development/quickstart\.html)

  1. Reference
     [https://proj\.org/development/reference/index\.html](https://proj\.org/development/reference/index\.html)

# <a name='section5'></a>Bugs, Todo, etc

  - commands implemented only sufficient to run example\.

# <a name='category'></a>CATEGORY

gis

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009\-2024 Peter Dean
