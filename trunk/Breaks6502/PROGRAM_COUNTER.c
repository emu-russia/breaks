#include "Breaks6502.h"
#include "Breaks6502Private.h"

// Program counter use optimized carry chain, which is inverted every next stage.
// Details here: http://forum.6502.org/viewtopic.php?f=8&t=2208&start=30#p20371

// Increment PC when IPC = 0

// PCLS/PCHS get inverted after each increment.

void ProgramCounter (Context6502 * cpu)
{
    int i, PCLC = 1, PCHC, carry_in, carry_out;

    if ( cpu->DRIVEREG[DRIVE_IPC] ) PCLC = 0;

    // LOW

    carry_out = cpu->DRIVEREG[DRIVE_IPC];

    for (i=0; i<8; i++) {
        if (cpu->DRIVEREG[DRIVE_ADL_PCL]) cpu->PCLS[i] = cpu->ADL[i];

        carry_in = carry_out;
        if ( i & 1 ) {
            carry_out = NAND( cpu->PCLS[i], carry_in );
            if (cpu->PHI2)
                cpu->PCL[i] = NOR(cpu->PCLS[i], carry_in) | NOT(carry_out);
            if (cpu->DRIVEREG[DRIVE_PCL_ADL]) cpu->ADL[i] = cpu->PCL[i];
            if (cpu->DRIVEREG[DRIVE_PCL_DB]) cpu->DB[i] = cpu->PCL[i];
            if (cpu->DRIVEREG[DRIVE_PCL_PCL]) cpu->PCLS[i] = cpu->PCL[i];
        }
        else {
            carry_out = NOR( NOT(cpu->PCLS[i]), carry_in );
            if (cpu->PHI2)
                cpu->PCL[i] = NOR( NOT(cpu->PCLS[i]) & carry_in, carry_out );
            if (cpu->DRIVEREG[DRIVE_PCL_ADL]) cpu->ADL[i] = NOT(cpu->PCL[i]);
            if (cpu->DRIVEREG[DRIVE_PCL_DB]) cpu->DB[i] = NOT(cpu->PCL[i]);
            if (cpu->DRIVEREG[DRIVE_PCL_PCL]) cpu->PCLS[i] = NOT(cpu->PCL[i]);
        }
        if (cpu->PCLS[i] == 0) PCLC = 0;
    }
    printf ( "PCLC = %i ", PCLC);

    // HIGH

    PCHC = PCLC;        // PCLC get set, when require to carry out on PCH
    carry_out = PCLC;

    for (i=0; i<4; i++) {       // bottom nibble
        if (cpu->DRIVEREG[DRIVE_ADH_PCH]) cpu->PCHS[i] = cpu->ADH[i];
        carry_in = carry_out;
        if ( i & 1 ) {
            carry_out = NOR( NOT(cpu->PCHS[i]), carry_in );
            if (cpu->PHI2)
                cpu->PCH[i] = NOR( NOT(cpu->PCHS[i]) & carry_in, carry_out );
            if (cpu->DRIVEREG[DRIVE_PCH_ADH]) cpu->ADH[i] = NOT(cpu->PCH[i]);
            if (cpu->DRIVEREG[DRIVE_PCH_DB]) cpu->DB[i] = NOT(cpu->PCH[i]);
            if (cpu->DRIVEREG[DRIVE_PCH_PCH]) cpu->PCHS[i] = NOT(cpu->PCH[i]);
        }
        else {
            carry_out = NAND( cpu->PCHS[i], carry_in );
            if (cpu->PHI2)
                cpu->PCH[i] = NOR(cpu->PCHS[i], carry_in) | NOT(carry_out);
            if (cpu->DRIVEREG[DRIVE_PCH_ADH]) cpu->ADH[i] = cpu->PCH[i];
            if (cpu->DRIVEREG[DRIVE_PCH_DB]) cpu->DB[i] = cpu->PCH[i];
            if (cpu->DRIVEREG[DRIVE_PCH_PCH]) cpu->PCHS[i] = cpu->PCH[i];
        }
        if (cpu->PCHS[i] == 0) PCHC = 0;
    }

    // PCHC get set if require to carry out on top nibble.

    carry_out = PCHC;

    for (i=4; i<8; i++) {       // top nibble
        if (cpu->DRIVEREG[DRIVE_ADH_PCH]) cpu->PCHS[i] = cpu->ADH[i];
        carry_in = carry_out;
        if ( i & 1 ) {
            carry_out = NOR( NOT(cpu->PCHS[i]), carry_in );
            if (cpu->PHI2)
                cpu->PCH[i] = NOR( NOT(cpu->PCHS[i]) & carry_in, carry_out );
            if (cpu->DRIVEREG[DRIVE_PCH_ADH]) cpu->ADH[i] = NOT(cpu->PCH[i]);
            if (cpu->DRIVEREG[DRIVE_PCH_DB]) cpu->DB[i] = NOT(cpu->PCH[i]);
            if (cpu->DRIVEREG[DRIVE_PCH_PCH]) cpu->PCHS[i] = NOT(cpu->PCH[i]);
        }
        else {
            carry_out = NAND( cpu->PCHS[i], carry_in );
            if (cpu->PHI2)
                cpu->PCH[i] = NOR(cpu->PCHS[i], carry_in) | NOT(carry_out);
            if (cpu->DRIVEREG[DRIVE_PCH_ADH]) cpu->ADH[i] = cpu->PCH[i];
            if (cpu->DRIVEREG[DRIVE_PCH_DB]) cpu->DB[i] = cpu->PCH[i];
            if (cpu->DRIVEREG[DRIVE_PCH_PCH]) cpu->PCHS[i] = cpu->PCH[i];
        }
    }
}
