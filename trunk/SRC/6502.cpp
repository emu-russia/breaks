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

// 6502 random logic controls
enum { ADH_ABH, ADL_ABL, Y_SB, X_SB, ZERO_ADL0, ZERO_ADL1, ZERO_ADL2,
    SB_Y, SB_X, S_SB, S_ADL, SB_S, S_S, NDB_ADD, DB_ADD,
    ZERO_ADD, SB_ADD, ADL_ADD, ANDS, EORS, ORS, _ACIN, SRS, SUMS, _DAA,
    ADD_SB7, ADD_SB06, ADD_ADL, _DSA, AVR, ACR, ZERO_ADH0, SB_DB, SB_AC,
    SB_ADH, ZERO_ADH17, AC_SB, AC_DB, ADH_PCH, PCH_PCH, PCH_DB, PCL_DB,
    PCH_ADH, PCL_PCL, PCL_ADL, ADL_PCL, ONE_PC, DL_ADL, DL_ADH, DL_DB,
    DB_P, IR5_I, IR5_C, DB_C, ACR_C, IR5_D, DBZ_Z, ONE_V, ZERO_V, DB_V, AVR_V, DB_N, P_DB,
    CTRL_MAX,
};

// flag index
enum { C_FLAG = 0, Z_FLAG, I_FLAG, D_FLAG, B_FLAG, X_FLAG, V_FLAG, N_FLAG };

static  int RandomData;

static  int _NMIP, NMIP_FF;
static  int _IRQP, IRQP_FF, IRQPLatch;
static  int RESP, RESP_FF, RESPLatch;
static  int SOInputLatch, SODelay1, SODelay2, SOOut;

static  int T1, TRES2;
static  int _T2, _T3, _T4, _T5;
static  int SR_input_latch;        // extended cycle counter  input latch
static  int SRin[4], SRout[4];      // extended cycle counter shift register

static  int _ready, RDY, _PRDY, NotReady1, ReadyDelay, REST;
static  int PRDYInLatch, PRDYOutLatch, ReadyOutLatch, ReadyInLatch;

static  int ACRL1, ACRL2, ACRLOutLatch, ACRLInLatch;
static  int _SHIFT, WR, RD_DL, WRLatch, WROut;

static  int _DONMI, BRKDELAY, BRKDONE;
static  int BRK5Latch, BRKDelayLatch, BRKDONELatch;
static  int NMIEndLatch, NMIDelayLatch;
static  int NMIG_Latch, NMIG_SetLatch, NMIG_ResetLatch;
static  int NMIL_Latch, NMIL_SetLatch, NMIL_ResetLatch;
static  int DORES_Input, DORES_Output, DORES;

static  int ZERO_IR, FETCH, FetchLatch;
static  int PD[8], PDLatch[8], _TWOCYCLE, IMPLIED, _IR[8], DECODER[130], IR01;

static  int POUT[8];    // flag output
static  int FlagLatch2[8], FlagLatch1[8];

static  int CtrlOutPHI1[CTRL_MAX], CtrlOutPHI2[CTRL_MAX], CTRL[CTRL_MAX];

static  int BinaryCarry, DecimalCarry, AVROut;

static  int SB[8], DB[8], ADH[8], ADL[8];   // internal buses


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

    // IRQ pad
    { "/IRQ", &pads_6502._IRQ, 748, 132 },
    { "", &PHI2, 935, 395 },
    { "/IRQP", &_IRQP, 969, 486 },
    { "", &IRQP_FF, 871, 362 },
    { "", &IRQPLatch, 911, 427 },

    // RES pad
    { "/RES", &pads_6502._RES, 1891, 134 },
    { "RESP", &RESP, 2039, 413 },
    { "", &RESPLatch, 1965, 326 },
    { "", &RESP_FF, 1831, 351 },

    // SO pad
    { "SO", &pads_6502.SO, 2629, 135 },
    { "", &SOInputLatch, 2808, 267 },
    { "", &SODelay1, 2698, 429 },
    { "", &SODelay2, 2753, 347 },
    { "", &SOOut, 2675, 446 },

    // interrupt control
    { "BRK5", &DECODER[22], 355, 1384 },
    { "BRKDONE", &BRKDONE, 320, 1291 },
    { "BRKDELAY", &BRKDELAY, 379, 1599 },
    { "", &BRK5Latch, 229, 1437 },
    { "", &BRKDONELatch, 177, 1336 },
    { "", &BRKDelayLatch, 139, 1544 },
    { "", &NMIDelayLatch, 267, 1134 },
    { "", &NMIEndLatch, 153, 1094 },
    { "", &NMIG_Latch, 310, 1032 }, { "", &NMIG_SetLatch, 345, 1063 }, { "", &NMIG_ResetLatch, 286, 901 },
    { "", &NMIL_Latch, 192, 1149 }, { "", &NMIL_SetLatch, 200, 1223 }, { "", &NMIL_ResetLatch, 368, 1105 },
    { "/DONMI", &_DONMI, 346, 1230 },
    { "/NMIP", &_NMIP, 88, 1022 },
    { "", &BRKDONE, 1198, 2415 },
    { "", &DORES, 1299, 2340 },
    { "", &DORES_Input, 991, 1957 },
    { "", &DORES_Output, 970, 2041 },
    { "DORES", &DORES, 831, 1877 },
    { "RESP", &RESP, 994, 1862 },
    { "", &BRKDONE, 910, 2097 },

    // extended cycle counter (shift register)
    { "T1", &T1, 260, 873 },
    { "TRES2", &TRES2, 333, 834 },
    { "/ready", &_ready, 128, 903 + 0*16 },
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

    // instruction register
    { "/IR0", &_IR[0], 4459, 569 + 0*16 },
    { "/IR1", &_IR[1], 4459, 569 + 1*16 },
    { "/IR2", &_IR[2], 4459, 569 + 2*16 },
    { "/IR3", &_IR[3], 4459, 569 + 3*16 },
    { "/IR4", &_IR[4], 4459, 569 + 4*16 },
    { "/IR5", &_IR[5], 4459, 569 + 5*16 },
    { "/IR6", &_IR[6], 4459, 569 + 6*16 },
    { "/IR7", &_IR[7], 4459, 569 + 7*16 },

    // fetch control
    { "FETCH", &FETCH, 4452, 733 },
    { "FETCH", &FETCH, 4070, 1625 },
    { "", &POUT[B_FLAG], 3943, 1630 },
    { "0/IR", &ZERO_IR, 4088, 1695 },
    { "", &FetchLatch, 3978, 1756 },
    { "", &T1, 3885, 1709 },
    { "", &_ready, 3956, 1717 },

    // predecode logic
    { "/TWOCYCLE", &_TWOCYCLE, 3930, 1395 },
    { "IMPLIED", &IMPLIED, 3841, 1682 },
    { "PD0", &PD[0], 4527, 1480 + 0*16 },
    { "PD1", &PD[1], 4527, 1480 + 1*16 },
    { "PD2", &PD[2], 4527, 1480 + 2*16 },
    { "PD3", &PD[3], 4527, 1480 + 3*16 },
    { "PD4", &PD[4], 4527, 1480 + 4*16 },
    { "PD5", &PD[5], 4527, 1480 + 5*16 },
    { "PD6", &PD[6], 4527, 1480 + 6*16 },
    { "PD7", &PD[7], 4527, 1480 + 7*16 },

    // ready control
    { "", &_ready, 2897, 1706 },
    { "RDY", &pads_6502.RDY, 1439, 131 },
    { "RDY", &RDY, 1610, 432 },
    { "_PRDY", &_PRDY, 1523, 448 },
    { "", &_PRDY, 2403, 523 },
    { "", &NotReady1, 2801, 1858 },
    { "", &ReadyDelay, 2865, 1951 },
    { "DORES", &DORES, 3069, 1446 },
    { "", &REST, 3051, 1530 },
    { "", &ReadyInLatch, 3011, 1647 },

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

    { "", &DECODER[97], 3130, 1179 },
    { "", &DECODER[106], 3422, 1179 },
    { "", &DECODER[107], 3447, 1179 },

    // random logic
    { "SYNC", &pads_6502.SYNC, 319, 1790 },
    { "T1", &T1, 585, 1772 },
    { "", &ACRL1, 2716, 2203 },
    { "", &ACRL2, 2784, 1847 },
    { "", &ACRLOutLatch, 2818, 2303 },
    { "", &ACRLInLatch, 2841, 2181 },
    { "", &REST, 2681, 1578 },
    { "", &ACRL2, 2686, 1641 },
    { "/ready", &_ready, 2677, 1705 },
    { "", &WRLatch, 3138, 1619 },
    { "WR", &WR, 3162, 1714 },
    { "WR", &WR, 4104, 511 },
    { "", &WROut, 4186, 463 },
    { "R/W", &pads_6502.RW, 4491, 140 },
    { "WR", &WR, 4118, 2576 },
    { "", &WROut, 4096, 2706 },
    { "RD", &RD_DL, 3823, 2840 },

    // control outputs
    { "", &CTRL[ADH_ABH], 636, 2857 },
    { "", &CTRL[ADL_ABL], 788, 2888 },
    { "", &CTRL[Y_SB], 775, 2824 },
    { "", &CTRL[X_SB], 827, 2822 },
    { "", &CTRL[SB_Y], 950, 2829 },
    { "", &CTRL[SB_X], 1007, 2836 },
    { "", &CTRL[S_SB], 1071, 2842 },
    { "", &CTRL[S_ADL], 1131, 2846 },
    { "", &CTRL[SB_S], 1189, 2823 },
    { "", &CTRL[S_S], 1245, 2817 },
    { "", &CTRL[NDB_ADD], 1306, 2816 },
    { "", &CTRL[DB_ADD], 1364, 2819 },
    { "", &CTRL[ZERO_ADD], 1420, 2812 },
    { "", &CTRL[SB_ADD], 1481, 2817 },
    { "", &CTRL[ADL_ADD], 1545, 2842 },
    { "", &CTRL[ANDS], 1615, 2850 },
    { "", &CTRL[EORS], 1646, 2828 },
    { "", &CTRL[ORS], 1723, 2831 },
    { "", &CTRL[_ACIN], 1751, 2860 },
    { "", &CTRL[SRS], 1787, 2849 },
    { "", &CTRL[SUMS], 1856, 2861 },
    { "", &CTRL[_DAA], 1897, 2853 },
    { "", &CTRL[ADD_SB7], 1971, 2858 },
    { "", &CTRL[ADD_SB06], 2005, 2860 },
    { "", &CTRL[ADD_ADL], 2071, 2864 },
    { "", &CTRL[_DSA], 2098, 2821 },
    { "", &CTRL[ZERO_ADH0], 2117, 2824 },
    { "", &CTRL[SB_DB], 2176, 2854 },
    { "", &CTRL[SB_AC], 2232, 2847 },
    { "", &CTRL[SB_ADH], 2292, 2849 },
    { "", &CTRL[ZERO_ADH17], 2349, 2849 },
    { "", &CTRL[AC_SB], 2402, 2844 },
    { "", &CTRL[AC_DB], 2460, 2843 },
    { "", &CTRL[ADH_PCH], 2525, 2850 },
    { "", &CTRL[PCH_PCH], 2587, 2849 },
    { "", &CTRL[PCH_DB], 2645, 2849 },
    { "", &CTRL[PCL_DB], 2704, 2849 },
    { "", &CTRL[PCH_ADH], 2762, 2846 },
    { "", &CTRL[PCL_PCL], 2823, 2846 },
    { "", &CTRL[PCL_ADL], 2884, 2843 },
    { "", &CTRL[ADL_PCL], 2943, 2843 },
    { "", &CTRL[ONE_PC], 3026, 2819 },
    { "", &CTRL[DL_ADL], 3072, 2782 },
    { "", &CTRL[DL_ADH], 3129, 2785 },
    { "", &CTRL[DL_DB], 3187, 2783 },

    // flag controls
    { "P/DB", &CTRL[P_DB], 3717, 2526 + 0*16 },
    { "DB/P", &CTRL[DB_P], 3717, 2526 + 1*16 },
    { "IR5/I", &CTRL[IR5_I], 3347, 2048 },
    { "DB/N", &CTRL[DB_N], 4265, 2164 },
    { "1/V", &CTRL[ONE_V], 4162, 2203 + 0*16 },
    { "0/V", &CTRL[ZERO_V], 4162, 2203 + 1*16 },
    { "DB/V", &CTRL[DB_V], 4162, 2203 + 2*16 },
    { "AVR/V", &CTRL[AVR_V], 4162, 2203 + 3*16 },
    { "DBZ/Z", &CTRL[DBZ_Z], 3789, 2557 },
    { "IR5/C", &CTRL[IR5_C], 3363, 2200 + 0*16 },
    { "DB/C", &CTRL[DB_C], 3363, 2200 + 1*16 },
    { "ACR/C", &CTRL[ACR_C], 3363, 2200 + 2*16 },
    { "IR5/D", &CTRL[IR5_D], 3771, 2486 },

    // flags output
    { "C_FLAG", &POUT[C_FLAG], 3245, 2207 + 0*16 },
    { "Z_FLAG", &POUT[Z_FLAG], 3245, 2207 + 1*16 },
    { "I_FLAG", &POUT[I_FLAG], 3245, 2207 + 2*16 },
    { "D_FLAG", &POUT[D_FLAG], 3245, 2207 + 3*16 },
    { "B_FLAG", &POUT[B_FLAG], 3245, 2207 + 4*16 },
    { "V_FLAG", &POUT[V_FLAG], 3245, 2207 + 5*16 },
    { "N_FLAG", &POUT[N_FLAG], 3245, 2207 + 6*16 },
    { "B_FLAG", &POUT[B_FLAG], 1357, 2413 },

    // ALU
    { "ACR", &CTRL[ACR], 2026, 3702 },
    { "AVR", &CTRL[AVR], 2042, 4560 },
    { "", &BinaryCarry, 1931, 4451 },
    { "", &DecimalCarry, 1902, 4451 },
    { "", &AVROut, 1893, 4545 },

    // internal data bus
    { "", &DB[0], 3378, 2881 },
    { "", &DB[1], 3394, 2881 },
    { "", &DB[2], 3292, 2881 },
    { "", &DB[3], 3324, 2881 },
    { "", &DB[4], 3348, 2881 },
    { "", &DB[5], 3363, 2881 },
    { "", &DB[6], 3308, 2881 },
    { "", &DB[7], 3272, 2881 },

    // external data bus
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

unsigned long getIR () { return ~packreg (_IR, 8) & 0xff; }
void setIR (unsigned long value) { unpackreg (_IR, ~value & 0xff, 8); }
unsigned long getDATA () { return packreg (pads_6502.D, 8); }
void setDATA (unsigned long value) { unpackreg (pads_6502.D, value, 8); }
unsigned long getDB () { return packreg (DB, 8); }
void setDB (unsigned long value) { unpackreg (DB, value, 8); }
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
    { 3321, 2952, 40, 30, "Courier", 9, getDB, setDB, "%02X" },
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

static void IRQ_PAD ()
{
    int ffout = NAND (pads_6502._IRQ, PHI2) & NOT(IRQP_FF);
    if (PHI1) IRQPLatch = ffout;
    _IRQP = NOT(IRQPLatch);
    IRQP_FF = NAND ( NOT(pads_6502._IRQ), PHI2 ) & NOT (ffout);
}

static void RES_PAD ()
{
    int ffout = NAND ( pads_6502._RES, PHI2) & NOT(RESP_FF);
    if (PHI1) RESPLatch = NOT(ffout);
    RESP = NOT(RESPLatch);
    RESP_FF = NAND ( NOT(pads_6502._RES), PHI2 ) & NOT (ffout);
}

static void NMI_DETECT ()
{
    int ffout;
    if (PHI1)
    {
        NMIL_SetLatch = BRKDONE;
        NMIG_ResetLatch = _NMIP;
        NMIG_SetLatch = NOT (NMIDelayLatch);
        NMIL_ResetLatch = NOR(_NMIP, NOT(NMIEndLatch)) & NOT( NOR(NMIG_ResetLatch, NOR(NMIG_Latch, NMIG_SetLatch) ) );
        _DONMI = NOR ( NOR(NMIL_SetLatch, NMIL_Latch), NMIL_ResetLatch );
    }
    if (PHI2)
    {
        NMIEndLatch = BRKDELAY;
        ffout = NOR (NMIG_Latch, NMIG_SetLatch);
        NMIG_Latch = NOR (ffout, NMIG_ResetLatch);
        ffout = NOR (NMIL_Latch, NMIL_SetLatch);
        _DONMI = NOR (ffout, NMIL_ResetLatch);
        NMIL_Latch = NMIDelayLatch = _DONMI;
    }
}

static void INT_END ()
{
    int BRK5 = DECODER[22] & NOT(_ready);
    if (PHI2) BRK5Latch = BRK5;
    if (PHI1) {
        if (NOT(_ready)) BRKDelayLatch = NOT(BRK5Latch);
        else BRKDelayLatch = NOR ( NOT(BRKDelayLatch), BRK5Latch );
    }
    BRKDELAY = NOR ( NOT(BRKDelayLatch), BRK5 );
    if (PHI2) BRKDONELatch = NOT(BRKDelayLatch);
    BRKDONE = BRKDONELatch & NOT(_ready);

    NMI_DETECT();
}

static void EXT_CYCLE_COUNTER ()
{
    int shift_in, n, mux, tout[4];

    if (PHI2) SR_input_latch = T1;    // shift register input
    shift_in = SR_input_latch;

    for (n=0; n<4; n++) {       // shift register
        mux = NOT(_ready) ? NOT(shift_in) : NOT(SRout[n]);
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

static void Step6502_old ()
{
    PHI1 = NOT (PHI0);
    PHI2 = BIT (PHI0);

    if ( RandomData ) {
        unsigned char value = rand() % 256;
        unpackreg (pads_6502.D, value, 8);
    }

    NMI_PAD ();
    IRQ_PAD ();
    RES_PAD ();
    INT_END ();
    PREDECODE ();
    EXT_CYCLE_COUNTER ();
    pads_6502.SYNC = T1;

    PHI0 ^= 1;
    PHI1 = NOT (PHI0);
    PHI2 = BIT (PHI0);
}

static void Step6502 ()
{
    int n, ffout;

    PHI1 = NOT (PHI0);
    PHI2 = BIT (PHI0);

    if ( RandomData ) {
        unsigned char value = rand() % 256;
        unpackreg (pads_6502.D, value, 8);
    }

    if (PHI1)
    {
        // input pads
        _NMIP = NMIP_FF;            // NMI
        IRQPLatch = NOT(IRQP_FF);   // IRQ
        _IRQP = NOT(IRQPLatch);
        RESPLatch = RESP_FF;        // RES
        RESP = NOT(RESPLatch);
        PRDYOutLatch = NOT (PRDYInLatch);   // RDY
        _PRDY = NOT (PRDYOutLatch);
        RDY = pads_6502.RDY;
        SOInputLatch = NOT (pads_6502.SO);  // SO
        SODelay1 = NOT (SODelay2);
        SOOut = NOR ( SODelay1, NOT(SOInputLatch) );

        // Ready control
        _ready = ReadyOutLatch;
        NotReady1 = _ready;

        // interrupt control
        if (NOT(_ready)) BRKDelayLatch = NOT(BRK5Latch);
        else BRKDelayLatch = NOR ( NOT(BRKDelayLatch), BRK5Latch );
        BRKDONE = BRKDONELatch & NOT(_ready);
        // NMI detect
        NMIL_SetLatch = BRKDONE;
        NMIG_ResetLatch = _NMIP;
        NMIG_SetLatch = NOT (NMIDelayLatch);
        NMIL_ResetLatch = NOR(_NMIP, NOT(NMIEndLatch)) & NOT( NOR(NMIG_ResetLatch, NOR(NMIG_Latch, NMIG_SetLatch) ) );
        _DONMI = NOR ( NOR(NMIL_SetLatch, NMIL_Latch), NMIL_ResetLatch );
        // reset
        ffout = NOR ( DORES_Output, DORES_Input );
        DORES_Input = NOR ( ffout, BRKDONE );
        DORES = NOT (ffout);

        // output B flag.
        FlagLatch1[B_FLAG] = NOR(BRKDONE, FlagLatch2[B_FLAG]);
        POUT[B_FLAG] = NOR ( DORES, FlagLatch1[B_FLAG] );

        // fetch control.
        FETCH = NOR (_ready, NOT(FetchLatch) );
        ZERO_IR = NAND ( FETCH, POUT[B_FLAG] );

        // predecode logic.
        for (n=0; n<8; n++) PD[n] = PDLatch[n] & NOT(ZERO_IR);
        IMPLIED = NOT ( PD[0] | PD[2] | NOT(PD[3]) );
        _TWOCYCLE = NOT (  NOT( NOT(PD[0]) | PD[2] | NOT(PD[3]) | PD[4] ) |
                           NOT( PD[0] | PD[2] | PD[3] | PD[4] | NOT(PD[7]) ) |
                           (PD[1] | PD[4] | PD[7]) & IMPLIED );

        // load instruction register
        if ( FETCH )
        {
            for (n=0; n<8; n++) _IR[n] = NOT (PD[n]);
        }
        IR01 = NOT(_IR[0]) | NOT(_IR[1]);

        // get ALU carry and overflow output
        CTRL[ACR] = BinaryCarry | DecimalCarry;
        CTRL[AVR] = NOT (AVROut);

        // ACR Latch
        ACRL1 = NOT ( ACRLOutLatch );
        ACRL2 = NAND (NOT(CTRL[ACR]), ReadyDelay) & NOT ( NOR (ACRL1, ReadyDelay) );
        ACRLInLatch = ACRL2;

        // early decoder
        DECODER[97] = NOT (_IR[7] | NOT(_IR[5]) | NOT (_IR[6]) );
        DECODER[106] = NOT ( _IR[1] | _IR[6] );
        DECODER[107] = NOT ( _IR[1] | NOT(_IR[6]) | NOT(_IR[7]) );
        _SHIFT = NOR ( DECODER[106], DECODER[107] );

        // update ready logic and generate WR output
        REST = DORES & NAND (_SHIFT, NOT(DECODER[97]));
        WR = NOT ( _ready | REST | WRLatch );
        WROut = WR;
        RD_DL = 1;
        pads_6502.RW = NOT (WROut);
        ReadyInLatch = WR;

        // flag control commands.
        CTRL[DB_P] = NOR ( CtrlOutPHI2[DB_P], _ready );
        CTRL[IR5_I] = NOT ( CtrlOutPHI2[IR5_I] );
        CTRL[IR5_C] = NOT ( CtrlOutPHI2[IR5_C] );
        CTRL[DB_C] = NOT ( CtrlOutPHI2[DB_C] );
        CTRL[ACR_C] = NOT ( CtrlOutPHI2[ACR_C] );
        CTRL[IR5_D] = NOT ( CtrlOutPHI2[IR5_D] );
        CTRL[DBZ_Z] = NOT ( CtrlOutPHI2[DBZ_Z] );
        CTRL[AVR_V] = CtrlOutPHI2[AVR_V];
        CTRL[ONE_V] = CtrlOutPHI2[ONE_V];
        CTRL[ZERO_V] = NOT (CtrlOutPHI2[ZERO_V]);
        CTRL[DB_V] = NAND (CtrlOutPHI2[DB_P], CtrlOutPHI2[DB_V]);
        CTRL[AVR_V] = CtrlOutPHI2[AVR_V];
        CTRL[DB_N] = NAND (CtrlOutPHI2[DBZ_Z], CtrlOutPHI2[DB_P]) & NOT (CtrlOutPHI2[DB_N]);
        CTRL[P_DB] = NOT ( CtrlOutPHI2[P_DB] );
    }

    if (PHI2)
    {

    }

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
