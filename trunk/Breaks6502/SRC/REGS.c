// X, Y, S registers
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void Regs (Context6502 * cpu)
{
    int b;

    // Disconnect registers from internal buses during read mode.
    if ( cpu->PHI2 ) {
        cpu->DRIVEREG[DRIVE_Y_SB] = 
        cpu->DRIVEREG[DRIVE_SB_Y] = 
        cpu->DRIVEREG[DRIVE_X_SB] = 
        cpu->DRIVEREG[DRIVE_SB_X] = 
        cpu->DRIVEREG[DRIVE_SB_S] = 0;
    }

    for (b=0; b<8; b++) {
        if ( cpu->DRIVEREG[DRIVE_Y_SB] ) cpu->SB[b] = cpu->Y[b];
        if ( cpu->DRIVEREG[DRIVE_SB_Y] ) cpu->Y[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_X_SB] ) cpu->SB[b] = cpu->X[b];
        if ( cpu->DRIVEREG[DRIVE_SB_X] ) cpu->X[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_S_ADL] ) cpu->ADL[b] = NOT(cpu->S[b]);
        if ( cpu->DRIVEREG[DRIVE_S_SB] ) cpu->SB[b] = NOT(cpu->S[b]);
        if ( !cpu->DRIVEREG[DRIVE_S_S] && cpu->PHI2 ) cpu->S[b] = 1;
        if ( cpu->DRIVEREG[DRIVE_SB_S] ) cpu->S[b] = NOT(cpu->SB[b]);

        // Precharge SBus.
        if ( cpu->PHI2 ) cpu->SB[b] = 1;
    }
}
