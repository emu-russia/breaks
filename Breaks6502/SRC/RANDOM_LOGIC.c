// Ktulhu Brain simulator.
#include "Breaks6502.h"
#include "Breaks6502Private.h"

#define PHI1    cpu->PHI1
#define PHI2    cpu->PHI2

static void ready_control (Context6502 * cpu)
{
}

static void execution_control (Context6502 * cpu)
{
    int _break = 0;
    if (PHI2) cpu->FetchLatch = cpu->sync;
    cpu->fetch = cpu->FetchLatch & NOT(cpu->_ready);
    cpu->clearIR = NAND(_break, cpu->fetch);        // simulate BRK opcode
}

static void RW (Context6502 * cpu)
{
    cpu->RW = BIT(~cpu->RWOut);     // R/W pad output
}

// Drivers.
//

static void Y_SB (Context6502 * cpu)
{
    int p = 1;
    if ( PLA_IND_Y || PLA_ABS_Y || PLA_DEY_INY || PLA_TYA || PLA_CPY_INY ) p = 0;
    if ( PLA_ZPABS_XY && PLA_7 ) p = 0;
    if ( cpu->STOR && PLA_STY ) p = 0;
    if ( PHI2 ) cpu->DRVS[DRIVE_Y_SB] = p;
    cpu->DRIVEREG[DRIVE_Y_SB] = NOT(cpu->DRVS[DRIVE_Y_SB]) & NOT(PHI2);
}

static void X_SB (Context6502 * cpu)
{
    int p = 1;
    if ( PLA_IND_X || PLA_9 || PLA_10 || PLA_11 || PLA_TXS ) p = 0;
    if ( PLA_ZPABS_XY && NOT(PLA_7) ) p = 0;
    if ( cpu->STOR && PLA_PUTX ) p = 0;
    if ( PHI2 ) cpu->DRVS[DRIVE_X_SB] = p;
    cpu->DRIVEREG[DRIVE_X_SB] = NOT(cpu->DRVS[DRIVE_X_SB]) & NOT(PHI2);
}

// before PLA
void RandomLogicEarly (Context6502 * cpu)
{
    cpu->sync = NOT(cpu->SyncLatch);
    cpu->SYNC = cpu->sync;      // output pad.

    execution_control (cpu);
}

// after PLA
void RandomLogic (Context6502 * cpu)
{
    // common control lines

    cpu->MemOP = NOT ( PLA_MEM_ZPXY || PLA_MEM_ABS || PLA_MEM_ZP || PLA_MEM_IND || PLA_MEM_ABSXY );
    cpu->STOR = NOR(cpu->MemOP, NOT(PLA_STORE));
    cpu->_SHIFT = NOT (PLA_106 || PLA_107);
    cpu->SS = NAND (cpu->_SHIFT, NOT(PLA_STORE) );

    RW (cpu);

    // Drivers.
    Y_SB (cpu);
    X_SB (cpu);
}
