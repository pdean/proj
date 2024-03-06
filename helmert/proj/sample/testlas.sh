#!/bin/sh

las2las64 -i g.txt -iparse xyz \
    -transform_affine 0.99960269575,1.55774140637E-04,-20.3070168478,-17.3858693056 \
    -rescale 0.001 0.001 0.001 -stdout -otxt    
