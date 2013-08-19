// 6502 sim
#include "Debug.h"
#include "6502.h"

// 6502 context.
Pads6502 pads_6502;

#define PHI0    pads_6502.PHI0
#define PHI1    pads_6502.PHI1
#define PHI2    pads_6502.PHI2

static  int _NMIP, NMIP_FF;

static  int T1, TRES2, ready;
static  int _T2, _T3, _T4, _T5;
static  int SR_input_latch;        // extended cycle counter  input latch
static  int SRin[4], SRout[4];      // extended cycle counter shift register


// Triggers.
static GraphTrigger trigs[] = {
    { "PHI0", &PHI0, 3699, 162 },
    { "PHI1", &PHI1, 965, 162 },
    { "PHI2", &PHI2, 2113, 162 },
    { "PHI1", &PHI1, 3031, 381 },
    { "PHI2", &PHI2, 3331, 406 },

    // NMI pad
    { "/NMI", &pads_6502._NMI, 172, 149 },
    { "", &PHI2, 607, 392 },
    { "/NMIP", &_NMIP, 150, 287 },
    { "", &NMIP_FF, 555, 378 },

    // extended cycle counter (shift register)
    { "T1", &T1, 260, 873 },
    { "TRES2", &TRES2, 333, 834 },
    { "ready", &ready, 128, 903 + 0*16 },
    { "PHI1", &PHI1, 128, 903 + 1*16 },
    { "PHI2", &PHI2, 128, 903 + 2*16 },
    { "", &SR_input_latch, 176, 874 },
    { "", &_T2, 398, 674 },
    { "", &_T3, 394, 625 },
    { "", &_T4, 406, 589 },
    { "", &_T5, 427, 540 },
    { "", &SRin[0], 265, 819 },  { "", &SRout[0], 207, 787 },
    { "", &SRin[1], 264, 708 },  { "", &SRout[1], 201, 623 },
    { "", &SRin[2], 205, 551 },  { "", &SRout[2], 204, 439 },
    { "", &SRin[3], 310, 433 },  { "", &SRout[3], 354, 338 },

    { "SYNC", &pads_6502.SYNC, 319, 1790 },
    { "T1", &T1, 585, 1772 },

};

// Basic logic
#define BIT(n)     ( (n) & 1 )
static int NOT(int a) { return (~a & 1); }
static int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
static int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

static void NMI_PAD ()
{
    int ffout = NAND (pads_6502._NMI, PHI2) & NOT(NMIP_FF);
    _NMIP = NOT(ffout);
    NMIP_FF = NAND ( NOT(pads_6502._NMI), PHI2 ) & NOT (ffout);
}

static void EXT_CYCLE_COUNTER ()
{
    int shift_in, n, mux, tout[4];

    if (PHI2) SR_input_latch = T1;    // shift register input
    shift_in = SR_input_latch;

    for (n=0; n<4; n++) {       // shift register
        mux = ready ? NOT(shift_in) : NOT(SRout[n]);
        if (PHI1) SRin[n] = mux;
        tout[n] = SRin[n] | TRES2;
        if (PHI2) SRout[n] = NOT (tout[n]);
        shift_in = SRout[n];
    }

    _T2 = tout[0];    // output current SR values
    _T3 = tout[1];
    _T4 = tout[2];
    _T5 = tout[3];
}

static void Step6502 ()
{
    PHI1 = NOT (PHI0);
    PHI2 = BIT (PHI0);

    NMI_PAD ();
    EXT_CYCLE_COUNTER ();
    pads_6502.SYNC = T1;

    PHI0 ^= 1;
    PHI1 = NOT (PHI0);
    PHI2 = BIT (PHI0);
}

DebugContext debug_6502 = {
    "6502",
    "files/6502.jpg",
    trigs,
    sizeof(trigs) / sizeof (GraphTrigger),
    Step6502
};
