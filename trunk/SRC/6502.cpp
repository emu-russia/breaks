// 6502 sim
#include "Debug.h"
#include "6502.h"

#include <iostream>
#include <algorithm>
#include <ctime>

// 6502 context.
Pads6502 pads_6502;

#define PHI0    pads_6502.PHI0
#define PHI1    pads_6502.PHI1
#define PHI2    pads_6502.PHI2

static  int RandomData;

static  int _NMIP, NMIP_FF;

static  int T1, TRES2, ready;
static  int _T2, _T3, _T4, _T5;
static  int SR_input_latch;        // extended cycle counter  input latch
static  int SRin[4], SRout[4];      // extended cycle counter shift register

static  int ZERO_IR, FETCH;
static  int PD[8], PDLatch[8], _TWOCYCLE, IMPLIED, IR[8], DECODER[130];


// Triggers.
static GraphTrigger trigs[] = {
    { "PHI0", &PHI0, 3699, 162 },
    { "PHI1", &PHI1, 965, 162 },
    { "PHI2", &PHI2, 2113, 162 },
    { "PHI1", &PHI1, 3031, 381 },
    { "PHI2", &PHI2, 3331, 406 },

    // debug
    { "Random data", &RandomData, 299, 40 },

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

    // instruction register
    { "IR0", &IR[0], 4459, 569 + 0*16 },
    { "IR1", &IR[1], 4459, 569 + 1*16 },
    { "IR2", &IR[2], 4459, 569 + 2*16 },
    { "IR3", &IR[3], 4459, 569 + 3*16 },
    { "IR4", &IR[4], 4459, 569 + 4*16 },
    { "IR5", &IR[5], 4459, 569 + 5*16 },
    { "IR6", &IR[6], 4459, 569 + 6*16 },
    { "IR7", &IR[7], 4459, 569 + 7*16 },

    // predecode logic
    { "/TWOCYCLE", &_TWOCYCLE, 3930, 1395 },
    { "IMPLIED", &IMPLIED, 3841, 1682 },
    { "0/IR", &ZERO_IR, 4088, 1695 },
    { "PD0", &PD[0], 4527, 1480 + 0*16 },
    { "PD1", &PD[1], 4527, 1480 + 1*16 },
    { "PD2", &PD[2], 4527, 1480 + 2*16 },
    { "PD3", &PD[3], 4527, 1480 + 3*16 },
    { "PD4", &PD[4], 4527, 1480 + 4*16 },
    { "PD5", &PD[5], 4527, 1480 + 5*16 },
    { "PD6", &PD[6], 4527, 1480 + 6*16 },
    { "PD7", &PD[7], 4527, 1480 + 7*16 },

    // decoder
    { "", &DECODER[0], 401, 1179 },
    { "", &DECODER[1], 424, 1179 },
    { "", &DECODER[2], 454, 1179 },
    { "", &DECODER[3], 478, 1179 },
    { "", &DECODER[4], 506, 1179 },
    { "", &DECODER[5], 535, 1179 },

    { "", &DECODER[6], 586, 1179 },
    { "", &DECODER[7], 610, 1179 },
    { "", &DECODER[8], 633, 1179 },
    { "", &DECODER[9], 656, 1179 },
    { "", &DECODER[10], 684, 1179 },
    { "", &DECODER[11], 712, 1179 },
    { "", &DECODER[12], 739, 1179 },
    { "", &DECODER[13], 758, 1179 },
    { "", &DECODER[14], 788, 1179 },
    { "", &DECODER[15], 810, 1179 },
    { "", &DECODER[16], 833, 1179 },
    { "", &DECODER[17], 858, 1179 },
    { "", &DECODER[18], 885, 1179 },
    { "", &DECODER[19], 912, 1179 },
    { "", &DECODER[20], 941, 1179 },

    // data bus
    { "D0", &pads_6502.D[0], 4450, 2933 },  { "", &pads_6502.D[0], 4270, 2040 },
    { "D1", &pads_6502.D[1], 4450, 3095 },  { "", &pads_6502.D[1], 4336, 2037 },
    { "D2", &pads_6502.D[2], 4450, 3324 },  { "", &pads_6502.D[2], 4422, 2023 },
    { "D3", &pads_6502.D[3], 4450, 3620 },  { "", &pads_6502.D[3], 4173, 2026 },
    { "D4", &pads_6502.D[4], 4450, 4063 },  { "", &pads_6502.D[4], 4150, 2030 },
    { "D5", &pads_6502.D[5], 4450, 4306 },  { "", &pads_6502.D[5], 4242, 2039 },
    { "D6", &pads_6502.D[6], 4450, 4587 },  { "", &pads_6502.D[6], 4480, 2016 },
    { "D7", &pads_6502.D[7], 4450, 4845 },  { "", &pads_6502.D[7], 4360, 2037 },

};

static GraphLocator locators[] = {
    { "ALU", 1212, 2870 },
    { "regs", 862, 2884 },
    { "PC", 2631, 2896 },
    { "IR", 4072, 486 },
};

unsigned long packreg ( int *reg, int bits )
{
    unsigned long val = 0, i;
    for (i=0; i<bits; i++) {
        if (reg[i]) val |= (1 << i);
    }
    return val;
}

void unpackreg (int *reg, unsigned long val, int bits)
{
    int i;
    for (i=0; i<bits; i++) {
        reg[i] = (val >> i) & 1;
    }
}

unsigned long getIR () { return packreg (IR, 8); }
void setIR (unsigned long value) { unpackreg (IR, value, 8); }
unsigned long getDATA () { return packreg (pads_6502.D, 8); }
void setDATA (unsigned long value) { unpackreg (pads_6502.D, value, 8); }
unsigned long getPD () { return packreg (PD, 8); }
void setPD (unsigned long value) { unpackreg (PD, value, 8); }

unsigned long getPHI0 ()
{
    static unsigned long out = 0;
    static int savedPHI0 = -1;
    if ( savedPHI0 != PHI0 ) {
        savedPHI0 = PHI0;
        out = (out << 4) | (PHI0 & 1);
    }
    return out;
}
void setPHI0 (unsigned long value) {}

static GraphCollector collectors[] = {
    { 4531, 506, 40, 30, "Courier", 9, getIR, setIR, "%02X" },
    { 3656, 110, 100, 30, "Courier", 12, getPHI0, setPHI0, "%08X" },
    { 4456, 2064, 40, 30, "Courier", 9, getDATA, setDATA, "%02X" },
    { 4546, 1417, 40, 30, "Courier", 9, getPD, setPD, "%02X" },
};

// ----------------------------------------------

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

static void PREDECODE ()
{
    for (int n=0; n<8; n++) {
        if (PHI2) PDLatch[n] = pads_6502.D[n];
        PD[n] = PDLatch[n] & NOT(ZERO_IR);
    }
    IMPLIED = NOT ( PD[0] | PD[2] | NOT(PD[3]) );
    _TWOCYCLE = NOT (  NOT( NOT(PD[0]) | PD[2] | NOT(PD[3]) | PD[4] ) |
                       NOT( PD[0] | PD[2] | PD[3] | PD[4] | NOT(PD[7]) ) |
                       (PD[1] | PD[4] | PD[7]) & IMPLIED    );
}

static void Step6502 ()
{
    PHI1 = NOT (PHI0);
    PHI2 = BIT (PHI0);

    if ( RandomData ) {
        unsigned char value = rand() % 256;
        unpackreg (pads_6502.D, value, 8);
    }

    NMI_PAD ();
    PREDECODE ();
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
    locators,
    sizeof(locators) / sizeof(GraphLocator),
    collectors,
    sizeof(collectors) / sizeof(GraphCollector),
    Step6502
};
