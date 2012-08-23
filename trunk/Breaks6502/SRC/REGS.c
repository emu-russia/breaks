// X, Y, S registers
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void Regs (Context6502 * cpu)
{
    int b;
    for (b=0; b<8; b++) {
        if ( cpu->DRIVEREG[DRIVE_Y_SB] ) cpu->SB[b] = cpu->Y[b];
        if ( cpu->DRIVEREG[DRIVE_SB_Y] ) cpu->Y[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_X_SB] ) cpu->SB[b] = cpu->X[b];
        if ( cpu->DRIVEREG[DRIVE_SB_X] ) cpu->X[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_S_ADL] ) cpu->ADL[b] = cpu->S[b];
        if ( cpu->DRIVEREG[DRIVE_S_SB] ) cpu->SB[b] = cpu->S[b];
        if ( cpu->DRIVEREG[DRIVE_SB_S] ) cpu->S[b] = cpu->SB[b];
        if ( cpu->DRIVEREG[DRIVE_S_S] ) cpu->S[b] = cpu->S[b];
    }
}
