// 6502 ALU.
// Genius decimal-mode correction also implemented.
#include "Breaks6502.h"
#include "Breaks6502Private.h"

// ALU using optimized carry chain, which is inverted every next stage.
// This allow to eliminate some silicon and reduce propagation delay.
// Details: http://forum.6502.org/viewtopic.php?f=8&t=2208&start=30#p20371

void ALU (Context6502 * cpu, int DecimalCorrection)
{
    int b;
    char NAND[8], NOR[8], ENOR[8], EOR[8];
    int ACR;    // ALU carry out
    int AVR;    // ALU overflow out
    int carry_in, carry_out;

    // Disconnect internal buses from ALU in read mode.
    if ( cpu->PHI2 ) {
        cpu->DRIVEREG[DRIVE_NOTDB_ADD] = 
        cpu->DRIVEREG[DRIVE_DB_ADD] = 
        cpu->DRIVEREG[DRIVE_ADL_ADD] = 
        cpu->DRIVEREG[DRIVE_SB_ADD] = 
        cpu->DRIVEREG[DRIVE_0_ADD] = 
        cpu->DRIVEREG[DRIVE_SB_AC] = 
        cpu->DRIVEREG[DRIVE_AC_SB] = 
        cpu->DRIVEREG[DRIVE_AC_DB] = 0;
    }

    // A/B INPUT
    for (b=0; b<8; b++) {
        if ( cpu->DRIVEREG[DRIVE_NOTDB_ADD] ) cpu->BI[b] = BIT(~cpu->DB[b]);
        if ( cpu->DRIVEREG[DRIVE_DB_ADD] ) cpu->BI[b] = cpu->DB[b];
        if ( cpu->DRIVEREG[DRIVE_ADL_ADD] ) cpu->BI[b] = cpu->ADL[b];
        if ( cpu->DRIVEREG[DRIVE_SB_ADD] ) cpu->AI[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_0_ADD] ) cpu->AI[b] = 0;
    }

    // LOGIC (based on NAND/NOR)
    for (b=0; b<8; b++) {
        NOR[b] = BIT(~(cpu->AI[b] | cpu->BI[b]));
        NAND[b] = BIT(~(cpu->AI[b] & cpu->BI[b]));
        if ( b & 1) EOR[b] = BIT(~(~NAND[b] | NOR[b]));
        else ENOR[b] = BIT(~(~NOR[b] & NAND[b]));

        if ( cpu->DRIVEREG[DRIVE_ORS] ) cpu->ADD[b] = NOR[b];
        if ( cpu->DRIVEREG[DRIVE_ANDS] ) cpu->ADD[b] = NAND[b];
        if ( cpu->DRIVEREG[DRIVE_SRS] && b ) cpu->ADD[b-1] = NAND[b];
        if ( cpu->DRIVEREG[DRIVE_EORS] ) {
            if ( b & 1 ) cpu->ADD[b] = BIT(~EOR[b]);
            else cpu->ADD[b] = ENOR[b];
        }
    }

    // ARITHMETIC
    // BCD correction run-flow : DAA -> ALU -> ADD -> DSA -> SB -> AC.

    // DECIMAL ADDER ADJUST (decimal carry and halfcarry ahead adjust)

    // Carry chain
    // input carry driver I_ADDC comes in inverted form

    // Carry out.

    // overflow test

    // ADDER HOLD (register holds data in inverted logic)

    // DECIMAL SBUS ADJUST (affects SBus lines)

    // ACCUMULATOR
    for (b=0; b<8; b++) {
        if ( cpu->DRIVEREG[DRIVE_SB_DB] ) cpu->DB[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_SB_AC] ) cpu->AC[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_AC_SB] ) cpu->SB[b] = cpu->AC[b];
        if ( cpu->DRIVEREG[DRIVE_AC_DB] ) cpu->DB[b] = cpu->AC[b];
        if ( cpu->DRIVEREG[DRIVE_0_ADH0] && b == 0 ) cpu->ADH[b] = 0;
        if ( cpu->DRIVEREG[DRIVE_0_ADH17] && b != 0 ) cpu->ADH[b] = 0;
    }
}
