
// 6502 pads
typedef struct Pads6502
{
    int PHI0, PHI1, PHI2;
    int _NMI, _IRQ, _RES;
    int SO, RW, RDY, SYNC;
    int A[16], D[8];
} Pads6502;

extern  Pads6502 pads_6502;

extern  DebugContext debug_6502;
