// 2C02 PPU pixel clock simulator.
#include <stdio.h>

int InLatch[2];
int OutLatch[2];

int PCLK (int CLK )
{
    int RES = 0;

    if ( CLK & 1 ) {
        InLatch[0] = (OutLatch[1] & 1) & ~RES;
        InLatch[1] = ~OutLatch[0] & 1;
    }
    else {
        OutLatch[0] = ~InLatch[0] & 1;
        OutLatch[1] = ~InLatch[1] & 1;
    }

    // dump counter
    //printf ( "%i %i %i %i \n", InLatch[0], InLatch[1], OutLatch[0], OutLatch[1] );

    return ~OutLatch[1] & 1;
}

main ()
{
    // initial conditions
    int CLK = 0, i;
    InLatch[0] = InLatch[1] = 0;
    OutLatch[0] = OutLatch[1] = 0;

    // Display master clock iterations
    printf ( "CLK : " );
    for (i=0; i<30; i++) {
        printf ( "%i", CLK );
        CLK ^= 1;
    }
    printf ( "\n" );

    // Display pixel clock iterations
    CLK = 0;
    printf ( "PCLK: " );
    for (i=0; i<30; i++) {
        printf ( "%i", PCLK (CLK) );
        CLK ^= 1;
    }
    printf ( "\n" );
}