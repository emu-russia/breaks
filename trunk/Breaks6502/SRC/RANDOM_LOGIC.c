// Ktulhu Brain simulator.
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void RandomLogicEarly (Context6502 * cpu)
{
}

void RandomLogic (Context6502 * cpu)
{
    #define PHI1    cpu->PHI1
    #define PHI2    cpu->PHI2
    int p;      // temporary value

    // Driver clock pullups
    // DT1/2 = PHI2

    // common control lines

    int MemOP = 1;
    if ( PLA_MEM_ZPXY || PLA_MEM_ABS || PLA_MEM_ZP || PLA_MEM_IND || PLA_MEM_ABSXY ) MemOP = 0;
    int STOR = NOR(MemOP, NOT(PLA_STORE));

    // =====================================  Y/SB

    p = 1;
    if ( PLA_IND_Y || PLA_ABS_Y || PLA_3 || PLA_4 || PLA_5 ) p = 0;
    if ( PLA_6 && PLA_7 ) p = 0;
    if ( STOR && PLA_0 ) p = 0;

    if ( PHI2 ) cpu->DRVStat[DRIVE_Y_SB] = p;
    cpu->DRIVEREG[DRIVE_Y_SB] = NOT(cpu->DRVStat[DRIVE_Y_SB]) & NOT(PHI2);

    // R/W pad output
    cpu->RW = BIT(~cpu->RWOut);
}
