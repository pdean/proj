#source zipper.tcl

package require tdom
dom createNodeCmd -returnNodeCmd elementNode Document
dom createNodeCmd -returnNodeCmd elementNode Folder
dom createNodeCmd -returnNodeCmd elementNode Placemark
dom createNodeCmd elementNode Style
dom createNodeCmd elementNode IconStyle
dom createNodeCmd elementNode Icon
dom createNodeCmd elementNode styleUrl
dom createNodeCmd elementNode name
dom createNodeCmd elementNode description
dom createNodeCmd elementNode href
dom createNodeCmd elementNode color
dom createNodeCmd elementNode Point
dom createNodeCmd elementNode coordinates
dom createNodeCmd cdataNode cdata
dom createNodeCmd textNode text

proc kmlout {points styles filename} {

    dom createDocument kml doc
    $doc documentElement root
    $root setAttribute xmlns http://www.opengis.net/kml/2.2
    $root appendFromScript { set document [Document] }

    set docname [file root [file tail $filename]]
    $document appendFromScript { name {text $docname} }

    foreach style $styles {
        lassign $style name href color
        $document appendFromScript {
            Style id $name {
                IconStyle {
                    Icon { href {text $href} }
                    color { text $color}
                }
            }
        }
    }

    foreach point $points {
        lassign $point name desc style lon lat elev
        $document appendFromScript {
            Placemark {
                name {text $name}
                styleUrl {text #$style}
                description {cdata $desc}
                Point {
                    coordinates {text "$lon,$lat,$elev"}
                }
            }
        }
    }

    set out [open $filename w]
    puts $out "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[$doc asXML -indent 4]"
    close $out

#    set kmz [file root $filename].kmz
#    zipper::initialize [open $kmz w]
#    zipper::addentry doc.kml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[$doc asXML -indent 4]"
#    close [zipper::finalize]
}




