// MOS 6502 clock-accurate emulator.
#include "6502.h"

#define PHI1    (cpu->PHI1)
#define PHI2    (cpu->PHI2)

// Basic logic
#define BIT(n)     ( (n) & 1 )
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

// Bottom-part controls
int ADH_ABH, ADL_ABL, Y_SB, X_SB, ZERO_ADL0, ZERO_ADL1, ZERO_ADL2,
    SB_Y, SB_X, S_SB, S_ADL, SB_S, S_S, nDB_ADD, DB_ADD,
    ZERO_ADD, SB_ADD, ADL_ADD, ANDS, EORS, ORS, I_ADDC, SRS, SUMS, nDAA,
    ADD_SB7, ADD_SB06, ADD_ADL, nDSA, AVR, ACR, ZERO_ADH0, SB_DB, SB_AC,
    SB_ADH, ZERO_ADH17, AC_SB, AC_DB, ADH_PCH, PCH_PCH, PCH_DB, PCL_DB,
    PCH_ADH, PCL_PCL, PCL_ADL, ADL_PCL, IPC, DL_ADL, DL_ADH, DL_DB;

// Top part context

// Bottom part context
static unsigned char X, Y, S, AI, BI, ADD, AC, PCL, PCLS, PCH, PCHS, DOR, DL, ABH, ABL;
unsigned char SB, DB, ADH, ADL;
static int OverflowLatch, BinaryCarry, DecimalCarry;
static int LatchDAAL, LatchDSAL, LatchDAAH, LatchDSAH;

// ---------------------------------------------------------------------------

void TopPart (M6502 *cpu)
{
    PHI1 = NOT(cpu->PHI0);
    PHI2 = cpu->PHI0;

    // interrupt pads
}

// ---------------------------------------------------------------------------

void DATA_LATCH_READ (M6502 *cpu)
{
}

void DATA_LATCH_WRITE (M6502 *cpu)
{
}

// Exchange X,Y,S registers with internal bus(es)
void XYS_REGS (M6502 *cpu)
{
    if (PHI1) {
        if (X_SB) SB = X;
        else if (SB_X) X = SB;
        if (Y_SB) SB = Y;
        else if (SB_Y) Y = SB;
        if (SB_S) S = SB;
        else if (S_SB) SB = S;
        if (S_ADL) ADL = S;
    }
    else if (PHI2) {
        if (S_SB) SB = S;
        if (S_ADL) ADL = S;
    }
}

void ALU (M6502 *cpu)
{

}

void PROGRAM_COUNTER (M6502 *cpu)
{
}

void ADDRESS_BUS (M6502 *cpu)
{
    ADL &= ~ ((ZERO_ADL2 << 2) | (ZERO_ADL1 << 1) | (ZERO_ADL0 << 0));
    if (ZERO_ADH0) ADH &= ~0x01;
    if (ZERO_ADH17) ADH &= ~0xFE;
    if (PHI1) {
        if (ADH_ABH) ABH = ADH;
        if (ADL_ABL) ABL = ADL;
    }
    cpu->ADDR = (ABH << 8) | ABL;
}

void BottomPart (M6502 *cpu)
{
    if (PHI2) SB = DB = ADH = ADL = 0xff;   // precharge internal buses
    if (PHI2) DATA_LATCH_READ (cpu);
    XYS_REGS (cpu);
    ALU (cpu);
    PROGRAM_COUNTER (cpu);
    if (PHI1) DATA_LATCH_WRITE (cpu);
    ADDRESS_BUS (cpu);
}

void Step6502 (M6502 *cpu)
{
    TopPart (cpu);
    BottomPart (cpu);
}

main ()
{
}