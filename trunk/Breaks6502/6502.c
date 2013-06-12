// MOS 6502 clock-accurate emulator.
#include "6502.h"

// Basic logic
#define BIT(n)     ( (n) & 1 )
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

void Step6502 (M6502 *cpu)
{
    // Top part context.
    #define PHI1    (cpu->PHI1)
    #define PHI2    (cpu->PHI2)

    static  unsigned char IR;
    static  char TWOCYCLE_Latch, TRESX_Latch, TRES1_Latch;
    static  char ReadyOut_Latch, ReadyIn_Latch;
    static  char T0_Latch, T1_Latch;
    static  char TX_Input[4], TX_Output[4];     // long (extended) cycle counter
    int     p;
    int     ready, nready;
    int     nT0, T0, nT1X, nT2, nT3, nT4, nT5;

    // Bottom part context.

    // Distribute clock pulses
    PHI1 = NOT(cpu->PHI0);
    PHI2 = BIT(cpu->PHI0);

    // HACK
    IR = 0x75;

    // ************ STEP 1 : Prepare decoder inputs, decode IR

    ready = NOT(ReadyOut_Latch);    // ready control line
    nready = NOT(ready);
    p = NOR ( TRES1_Latch, TWOCYCLE_Latch & TRESX_Latch );
    p = 0;
    printf ( "%i  ", p );
    if (PHI1) T1_Latch = NOR(T0_Latch, nready);
    nT1X = NOT(T1_Latch);
    nT0 = NOR ( p, NOR (T0_Latch, T1_Latch) );
    if (PHI2) T0_Latch = nT0;
    T0 = NOT(nT0);                  // T0/T1 output

    nT2 = NOT(TX_Output[0]);
    nT3 = NOT(TX_Output[1]);
    nT4 = NOT(TX_Output[2]);
    nT5 = NOT(TX_Output[3]);        // extended cycle counter outputs

    // ************ STEP 2

    // ************ STEP 3

    // ************ STEP 4
    
    printf ( "PHI:%i, T: %i%i%i%i%i%i, ready:%i\n", cpu->PHI0, nT0, nT1X, nT2, nT3, nT4, nT5, ready );
}

// Execute 1000 cycles.
main ()
{
    M6502 cpu;
    int cycles = 0;

    memset ( &cpu, 0, sizeof(M6502));

    cpu.RDY = 1;
    cpu.nNMI = cpu.nIRQ = cpu.nRES = 1;

    while (cycles++ < 1000)
    {
        Step6502 (&cpu);
        cpu.PHI0 ^= 1;
    }
}