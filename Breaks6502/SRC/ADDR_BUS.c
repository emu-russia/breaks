// Address Bus.
#include "Breaks6502.h"
#include "Breaks6502Private.h"

// ADH/ADL are high during PHI2 (precharged)

// ABH/ABL register latches are refreshed during PHI2.

void AddressBus (Context6502 * cpu)
{
    int b;

    for (b=0; b<8; b++) {
        if ( cpu->PHI2 ) cpu->ADH[b] = cpu->ADL[b] = 1;     // Precharge.
        if ( cpu->DRIVEREG[DRIVE_0_ADH0] && b == 0 ) cpu->ADH[b] = 0;
        if ( cpu->DRIVEREG[DRIVE_0_ADH17] && b != 0 ) cpu->ADH[b] = 0;
    }

    if (cpu->DRIVEREG[DRIVE_0_ADL0]) cpu->ADL[0] = 0;
    if (cpu->DRIVEREG[DRIVE_0_ADL1]) cpu->ADL[1] = 0;
    if (cpu->DRIVEREG[DRIVE_0_ADL2]) cpu->ADL[2] = 0;

    // Low
    for (b=0; b<8; b++) {
        if (cpu->PHI1 && cpu->DRIVEREG[DRIVE_ADL_ABL])
        {
            cpu->ABL[b] = NOT(cpu->ADL[b]);
        }
        if (cpu->PHI2) cpu->ABL[b] = cpu->ABL[b];   // refresh latch
        cpu->ADDR[b] = NOT(cpu->ABL[b]);
    }

    // High
    for (b=0; b<8; b++) {
        if (cpu->PHI1 && cpu->DRIVEREG[DRIVE_ADH_ABH])
        {
            cpu->ABH[b] = NOT(cpu->ADH[b]);
        }
        if (cpu->PHI2) cpu->ABH[b] = cpu->ABH[b];   // refresh latch
        cpu->ADDR[8+b] = NOT(cpu->ABH[b]);
    }
}
