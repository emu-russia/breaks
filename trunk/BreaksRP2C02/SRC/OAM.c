// OAM control, OAM buffer and row/column access select.
#include "PPU.h"

void OAM_RAS (Context2C02 *ppu)
{
}

void OAM_CAS (Context2C02 *ppu)
{
    OAM_CAS_0 = NOT (ppu->OAM[5] | ppu->OAM[6] | ppu->OAM[7] | ppu->OAM[8]);
    OAM_CAS_1 = NOT (NOT(ppu->OAM[5]) | ppu->OAM[6] | ppu->OAM[7] | ppu->OAM[8]);
    OAM_CAS_2 = NOT (ppu->OAM[5] | NOT(ppu->OAM[6]) | ppu->OAM[7] | ppu->OAM[8]);
    OAM_CAS_3 = NOT (NOT(ppu->OAM[5]) | NOT(ppu->OAM[6]) | ppu->OAM[7] | ppu->OAM[8]);
    OAM_CAS_4 = NOT (ppu->OAM[5] | ppu->OAM[6] | NOT(ppu->OAM[7]) | ppu->OAM[8]);
    OAM_CAS_5 = NOT (NOT(ppu->OAM[5]) | ppu->OAM[6] | NOT(ppu->OAM[7]) | ppu->OAM[8]);
    OAM_CAS_6 = NOT (ppu->OAM[5] | NOT(ppu->OAM[6]) | NOT(ppu->OAM[7]) | ppu->OAM[8]);
    OAM_CAS_7 = NOT (NOT(ppu->OAM[5]) | NOT(ppu->OAM[6]) | NOT(ppu->OAM[7]) | ppu->OAM[8]);
    OAM_CAS_Z = BIT(ppu->OAM[8]);

    if (ppu->DEBUG) {
        printf ( "OAM CAS 8765 -> 76543210Z: %i%i%i%i -> %i%i%i%i%i%i%i%i%i\n", 
            ppu->OAM[8], ppu->OAM[7], ppu->OAM[6], ppu->OAM[5], 
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
