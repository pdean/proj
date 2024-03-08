{
    a=$1; b=$2; xm=$3; ym=$4; XM=$5; YM=$6

    x0=XM-a*xm+b*ym
    y0=YM-b*xm-a*ym

    # scale rotation
    s=sqrt(a^2+b^2)
    t=atan2(b,a)
    rad2deg=45/atan2(1,1)
    rad2sec=3600*rad2deg
    t = -t*rad2sec

    # proj string
    printf("+proj=helmert")
    printf(" +convention=coordinate_frame")
    printf(" +x=%.5f",x0)
    printf(" +y=%.5f",y0)
    printf(" +s=%.16f",s)
    printf(" +theta=%.18f",t)
    printf("\n")

}
