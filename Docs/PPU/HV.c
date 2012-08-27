// PPU H/V counter simulation.
#include <stdio.h>

// Latches
int  HIN[9], HOUT[9];
int  VIN[9], VOUT[9];

int HCount (int PCLK)
{
    int i, in, hin, out[9], cnt;

    hin = 0;
    in = hin;

    for (i=0; i<9; i++) {
        if ( PCLK & 1 ) {
            HOUT[i] = ~HIN[i] & 1;
        }
        else {
            if (in) HIN[i] = HOUT[i];
            else HIN[i] = ~HOUT[i] & 1;
        }    
        out[i] = HOUT[i];

        if ( i == 4 ) in = ( ~ ( ~out[0] & ~out[1] & ~out[2] & ~out[3] & ~out[4] & ~hin ) ) & 1;
        else in = ( ~(out[i] & ~in) ) & 1;
    }

    cnt = 0;
    for (i=0; i<9; i++) {
        if ( out[i] ) cnt |= 1 << i;
    }
    return cnt;
}

int VCount (int PCLK)
{
    int i, in, out[9], cnt;

    in = 1;

    for (i=0; i<9; i++) {
        if ( PCLK & 1 ) {
            VOUT[i] = ~VIN[i] & 1;
        }
        else {
            if (in) VIN[i] = VOUT[i];
            else VIN[i] = ~VOUT[i] & 1;
        }    
        out[i] = VOUT[i];

        if ( i == 4 ) in = ( ~ ( ~out[0] & ~out[1] & ~out[2] & ~out[3] & ~out[4] ) ) & 1;
        else in = ( ~(out[i] & ~in) ) & 1;
    }

    cnt = 0;
    for (i=0; i<9; i++) {
        if ( out[i] ) cnt |= 1 << i;
    }
    return cnt;
}

main ()
{
    // initial conditions
    int PCLK = 0, i;
    for (i=0; i<9; i++) HIN[i] = HOUT[i] = VIN[i] = VOUT[i] = 0;

    // Count 1000 times
    for (i=0; i<1000; i++) {
        printf ( "%i: H=%i V=%i\n", i, HCount (PCLK), VCount (PCLK) );
        PCLK ^= 1;
    }
}