
typedef struct Context6502 {
    char nNMI;
    char nIRQ;
    char PHI1;
    char RDY;
    char nRES;
    char PHI2;
    char SO;
    char PHI0;
    char RW;
    unsigned char DATA;
    unsigned short ADDR;
    char SYNC;
} Context6502;

// Basic logic
#define BIT(n)     ( (n) & 1 )
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

int * DECODER (unsigned char IR, int T, int PNRDY);

#define PHI1  (cpu->PHI1)
#define PHI2  (cpu->PHI2)

void TOP (Context6502 * cpu, int ACR, int AVR)
{
    static int PNRDY_Latch[2], RDY_Latch[2], NRDY2_Latch[2], ACRLatch[2], ForceRead;
    static int BFLAG[2], IFLAG[2], DFLAG[2], CFLAG[2], VFLAG[2], NFLAG[2];
    static int NMILatch, IRQLatch[2], RESLatch[2];
    static unsigned char IR, PD;
    int nNMI, nIRQ, RES, BRK6E, DORES;    
    int RDY, PNRDY, TWOCYCLE, IMPLIED, nready, NRDY2, ACRL1, ACRL2, WR;
    int nBOUT, nIOUT, nDOUT, nCOUT, nVOUT, nNOUT;
    int b, p[4];

    // clock
    PHI1 = NOT(cpu->PHI0);
    PHI2 = BIT(cpu->PHI0);

    // /NMI pad
    nNMI = NAND(PHI2,NOT(cpu->nNMI)) & NOT(NMILatch);
    NMILatch = NAND(PHI2,cpu->nNMI) & NOT(nNMI);

    // ready pad
    RDY = cpu->RDY;
    if (PHI2) PNRDY_Latch[0] = NOT(RDY);
    if (PHI1) PNRDY_Latch[1] = NOT(PNRDY_Latch[0]);
    PNRDY = NOT (PNRDY_Latch[1]);

    // ready output
    nready = RDY_Latch[0];
    
    // nready PHI2
    if (PHI1) NRDY2_Latch[1] = nready;
    if (PHI2) NRDY2_Latch[0] = NOT(NRDY2_Latch[1]);
    NRDY2 = NOT (NRDY2_Latch[0]);

    // ACR latch
    ACRL1 = NOT (ACRLatch[0]);
    ACRL2 = NAND(NOT(ACR),NOT(NRDY2)) & (ACRL1|NOT(NRDY2));
    if (PHI1) ACRLatch[1] = ACRL2;
    if (PHI2) ACRLatch[0] = NOT(ACRLatch[1]);

    // ...

    // flags output
    nBOUT = NOR (DORES, NOR(BRK6E,BFLAG[0]));
    nIOUT = NOT (IFLAG[0]);
    nDOUT = NOT (DFLAG[0]);
    nCOUT = NOT (CFLAG[0]);
    nVOUT = NOT (VFLAG[0]);
    nNOUT = NOT (NFLAG[0]);

    // predecode
    // Determine whenever instruction takes 2 cycle / implied.
    #define PD(n)  ( (PD >> n) & 1 )  
    #define nPD(n) ( NOT((PD >> n) & 1) )
    if ( PHI2 ) PD = cpu->DATA;
    p[0] = NOT ( PD(2) | nPD(3) | PD(4) | nPD(0) );     // XXX010X1
    p[1] = NOT ( PD(2) | nPD(3) | PD(0) );      // XXXX10X0
    p[2] = NOT ( PD(4) | PD(7) | PD(1) );       // 0XX0XX0X
    p[3] = NOT ( PD(2) | PD(3) | PD(4) | nPD(7) | PD(0) );  // 1XX000X0
    TWOCYCLE = ( p[0] | p[3] | (NOT(p[2]) & p[1]) );
    IMPLIED = ( p[1] );

    // ...

    // ready input
    if (PHI1) RDY_Latch[1] = NOT (ForceRead | DORES | RDY_Latch[0]);
    if (PHI2) RDY_Latch[0] = NOR (RDY_Latch[1], RDY);
    nready = RDY_Latch[0];

}

main ()
{
    int nNMI, NMILatch = 1, old;
    int _PHI2 = 1;
    Context6502 cpu;

    cpu.nNMI = 1;

    old = NMILatch;
    nNMI = NAND(_PHI2,NOT(cpu.nNMI)) & NOT(NMILatch);
    NMILatch = NAND(_PHI2,cpu.nNMI) & NOT(nNMI);

    printf ( "in l | l* out\n");
    printf ( "%i %i | %i %i\n", cpu.nNMI, old, NMILatch, nNMI );
}
