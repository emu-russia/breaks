// Test suite.
#include <stdio.h>
#include "PPU.h"

// --------------------------------------------------------------------

/*
CLK : 010101010101010101010101010101
PCLK: 000011110000111100001111000011
*/
static void PIXEL_CLOCK_DEBUG (Context2C02 *ppu)
{
    int i;
    ppu->CLK = 0;

    ppu->DEBUG = 0;

    // Display master clock iterations
    printf ( "CLK : " );
    for (i=0; i<30; i++) {
        printf ( "%i", ppu->CLK );
        ppu->CLK ^= 1;
    }
    printf ( "\n" );

    // Display pixel clock iterations
    ppu->CLK = 0;
    printf ( "PCLK: " );
    for (i=0; i<30; i++) {
        PIXEL_CLK (ppu);
        printf ( "%i", ppu->PCLK );
        ppu->CLK ^= 1;
    }
    printf ( "\n" );
}

// --------------------------------------------------------------------

/*
OAM CAS 8765 -> 76543210Z: 0000 -> 000000010
OAM CAS 8765 -> 76543210Z: 0001 -> 000000100
OAM CAS 8765 -> 76543210Z: 0010 -> 000001000
OAM CAS 8765 -> 76543210Z: 0011 -> 000010000
OAM CAS 8765 -> 76543210Z: 0100 -> 000100000
OAM CAS 8765 -> 76543210Z: 0101 -> 001000000
OAM CAS 8765 -> 76543210Z: 0110 -> 010000000
OAM CAS 8765 -> 76543210Z: 0111 -> 100000000
OAM CAS 8765 -> 76543210Z: 1000 -> 000000001
OAM CAS 8765 -> 76543210Z: 1001 -> 000000001
OAM CAS 8765 -> 76543210Z: 1010 -> 000000001
OAM CAS 8765 -> 76543210Z: 1011 -> 000000001
OAM CAS 8765 -> 76543210Z: 1100 -> 000000001
OAM CAS 8765 -> 76543210Z: 1101 -> 000000001
OAM CAS 8765 -> 76543210Z: 1110 -> 000000001
OAM CAS 8765 -> 76543210Z: 1111 -> 000000001
*/
static void OAM_CAS_DEBUG (Context2C02 *ppu)
{
    int i, old = ppu->DEBUG;
    ppu->DEBUG = 1;
    for (i=0; i<16; i++) {
        ppu->OAM[5] = BIT ( i >> 0 );
        ppu->OAM[6] = BIT ( i >> 1 );
        ppu->OAM[7] = BIT ( i >> 2 );
        ppu->OAM[8] = BIT ( i >> 3 );
        OAM_CAS (ppu);
    }
    ppu->DEBUG = old;
}

main ()
{
    Context2C02 ppu;
    memset (&ppu, 0, sizeof(ppu));

    // PIXEL_CLOCK_DEBUG (&ppu);
    // OAM_CAS_DEBUG (&ppu);

    printf ("PPU test suite.\n");
}
