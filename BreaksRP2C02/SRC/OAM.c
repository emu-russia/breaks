// OAM control, OAM buffer and row/column access select.
#include "PPU.h"

void OAM_RAS (Context2C02 *ppu)
{
    int i;

    ppu->OAM_RAS[0] = NOT (NOT(OAM0) | NOT(OAM1) | NOT(OAM2) | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[1] = NOT (OAM0 | NOT(OAM1) | NOT(OAM2) | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[2] = NOT (NOT(OAM0) | OAM1 | NOT(OAM2) | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[3] = NOT (OAM0 | OAM1 | NOT(OAM2) | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[4] = NOT (NOT(OAM0) | NOT(OAM1) | OAM2 | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[5] = NOT (OAM0 | NOT(OAM1) | OAM2 | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[6] = NOT (NOT(OAM0) | OAM1 | OAM2 | NOT(OAM3) | NOT(OAM4));
    ppu->OAM_RAS[7] = NOT (OAM0 | OAM1 | OAM2 | NOT(OAM3) | NOT(OAM4));

    ppu->OAM_RAS[8] = NOT (NOT(OAM0) | NOT(OAM1) | NOT(OAM2) | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[9] = NOT (OAM0 | NOT(OAM1) | NOT(OAM2) | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[10] = NOT (NOT(OAM0) | OAM1 | NOT(OAM2) | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[11] = NOT (OAM0 | OAM1 | NOT(OAM2) | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[12] = NOT (NOT(OAM0) | NOT(OAM1) | OAM2 | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[13] = NOT (OAM0 | NOT(OAM1) | OAM2 | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[14] = NOT (NOT(OAM0) | OAM1 | OAM2 | OAM3 | NOT(OAM4));
    ppu->OAM_RAS[15] = NOT (OAM0 | OAM1 | OAM2 | OAM3 | NOT(OAM4));

    ppu->OAM_RAS[16] = NOT (NOT(OAM0) | NOT(OAM1) | NOT(OAM2) | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[17] = NOT (OAM0 | NOT(OAM1) | NOT(OAM2) | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[18] = NOT (NOT(OAM0) | OAM1 | NOT(OAM2) | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[19] = NOT (OAM0 | OAM1 | NOT(OAM2) | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[20] = NOT (NOT(OAM0) | NOT(OAM1) | OAM2 | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[21] = NOT (OAM0 | NOT(OAM1) | OAM2 | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[22] = NOT (NOT(OAM0) | OAM1 | OAM2 | NOT(OAM3) | OAM4);
    ppu->OAM_RAS[23] = NOT (OAM0 | OAM1 | OAM2 | NOT(OAM3) | OAM4);

    ppu->OAM_RAS[24] = NOT (NOT(OAM0) | NOT(OAM1) | NOT(OAM2) | OAM3 | OAM4);
    ppu->OAM_RAS[25] = NOT (OAM0 | NOT(OAM1) | NOT(OAM2) | OAM3 | OAM4);
    ppu->OAM_RAS[26] = NOT (NOT(OAM0) | OAM1 | NOT(OAM2) | OAM3 | OAM4);
    ppu->OAM_RAS[27] = NOT (OAM0 | OAM1 | NOT(OAM2) | OAM3 | OAM4);
    ppu->OAM_RAS[28] = NOT (NOT(OAM0) | NOT(OAM1) | OAM2 | OAM3 | OAM4);
    ppu->OAM_RAS[29] = NOT (OAM0 | NOT(OAM1) | OAM2 | OAM3 | OAM4);
    ppu->OAM_RAS[30] = NOT (NOT(OAM0) | OAM1 | OAM2 | OAM3 | OAM4);
    ppu->OAM_RAS[31] = NOT (OAM0 | OAM1 | OAM2 | OAM3 | OAM4);

    if (ppu->DEBUG) {
        printf ( "OAM RAS 43210 -> [31..0]: %i%i%i%i%i -> ", 
            OAM4, OAM3, OAM2, OAM1, OAM0 );
        for (i=0; i<32; i++) printf ("%i", ppu->OAM_RAS[i]);
        printf ("\n");
    }
}

void OAM_CAS (Context2C02 *ppu)
{
    OAM_CAS_0 = NOT (OAM5 | OAM6 | OAM7 | OAM8);
    OAM_CAS_1 = NOT (NOT(OAM5) | OAM6 | OAM7 | OAM8);
    OAM_CAS_2 = NOT (OAM5 | NOT(OAM6) | OAM7 | OAM8);
    OAM_CAS_3 = NOT (NOT(OAM5) | NOT(OAM6) | OAM7 | OAM8);
    OAM_CAS_4 = NOT (OAM5 | OAM6 | NOT(OAM7) | OAM8);
    OAM_CAS_5 = NOT (NOT(OAM5) | OAM6 | NOT(OAM7) | OAM8);
    OAM_CAS_6 = NOT (OAM5 | NOT(OAM6) | NOT(OAM7) | OAM8);
    OAM_CAS_7 = NOT (NOT(OAM5) | NOT(OAM6) | NOT(OAM7) | OAM8);
    OAM_CAS_Z = BIT (OAM8);

    if (ppu->DEBUG) {
        printf ( "OAM CAS 8765 -> 76543210Z: %i%i%i%i -> %i%i%i%i%i%i%i%i%i\n", 
            OAM8, OAM7, OAM6, OAM5, 
            OAM_CAS_7, OAM_CAS_6, OAM_CAS_5, OAM_CAS_4, OAM_CAS_3, OAM_CAS_2, OAM_CAS_1, OAM_CAS_0, 
            OAM_CAS_Z );
    }
}

void OAM_CTRL (Context2C02 *ppu)
{
}

void OAM_BUF (Context2C02 *ppu)
{
}
