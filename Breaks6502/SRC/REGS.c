// X, Y, S registers
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void Regs (Context6502 * cpu)
{
    int b;
    if ( cpu->DRIVEREG[DRIVE_Y_SB] ) {
        for (b=0; b<8; b++) cpu->SB[b] = cpu->Y[b];
    }
    if ( cpu->DRIVEREG[DRIVE_SB_Y] ) {
        for (b=0; b<8; b++) cpu->Y[b] = cpu->SB[b];
    }
    if ( cpu->DRIVEREG[DRIVE_X_SB] ) {
        for (b=0; b<8; b++) cpu->SB[b] = cpu->X[b];
    }
    if ( cpu->DRIVEREG[DRIVE_SB_X] ) {
        for (b=0; b<8; b++) cpu->X[b] = cpu->SB[b];
    }
    if ( cpu->DRIVEREG[DRIVE_S_ADL] ) {
        for (b=0; b<8; b++) cpu->ADL[b] = cpu->S[b];
    }
    if ( cpu->DRIVEREG[DRIVE_S_SB] ) {
        for (b=0; b<8; b++) cpu->SB[b] = cpu->S[b];
    }
    if ( cpu->DRIVEREG[DRIVE_SB_S] ) {
        for (b=0; b<8; b++) cpu->S[b] = cpu->SB[b];
    }
    if ( cpu->DRIVEREG[DRIVE_S_S] ) {
        for (b=0; b<8; b++) cpu->S[b] = cpu->S[b];
    }
}
