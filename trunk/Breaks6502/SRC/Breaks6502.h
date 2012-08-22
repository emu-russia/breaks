
typedef struct Context6502
{
    // Inputs
    int         PHI0;
    int         NMI, IRQ, RDY, RES, SO;

    // Outputs
    int         RW, SYNC;
    char        PHI1, PHI2;         // Timing

    // Buses
    char        DATA[8], ADDR[16];

    // Top part internal state
    char        PD[8];              // Predecode register
    char        IR[8];              // Instruction register
    char        TR[6];              // T-state register
    char        DRIVEREG[64];

    // Bottom part internal state
    char        SB[8], DB[8];           // SBus, DBus
    char        X[8], Y[8], S[8];       // X, Y, S registers
    char        ABH[8], ABL[8];         // Address bus registers
    char        ADH[8], ADL[8];         // Internal address bus

    int         ACR;        // ALU carry out
    int         AVR;        // ALU overflow out

    char        PCL[8], PCLS[8], PCH[8], PCHS[8];   // Program Counter    

} Context6502;

void    Step6502 ( Context6502 * cpu );
