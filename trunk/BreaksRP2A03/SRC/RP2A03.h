// Ricoh 2A03 APU simulator.

typedef struct Core6502
{
    int         NoDecimalCorrection;        // disable BCD ALU correction if set
    int         DEBUG;                      // do some debug printf
    int         PHI0;                       // Inputs
    int         NMI, IRQ, RDY, RES, SO;
    int         RW, SYNC;                   // Outputs
    char        PHI1, PHI2;
    char        DATA[8], ADDR[16];          // Buses
    char        private[];                  // Internal state.. we dont need it.
} Core6502;

typedef struct Context2A03 {

    Core6502    *cpu;       // embedded 6502 core.

    int     REGSEL[12];     // register select PLA result
} Context2A03;
