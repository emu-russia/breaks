#include "Debug.h"

// ALU context.

int     PHI0, PHI1, PHI2;

int     SB[8], DB[8], ADL[8];
int     ALU_NDB_ADD, ALU_DB_ADD, ALU_ADL_ADD, ALU_SB_ADD, ALU_0_ADD;
int     ALU_ADD_ADL, ALU_ADD_SB06, ALU_ADD_SB7;
int     ALU_1ADDC, ALU_ORS, ALU_ANDS, ALU_EORS, ALU_SRS, ALU_SUMS;
int     AI[8], BI[8], ADD[8];

// Triggers.
static GraphTrigger trigs[] = {
    { "PHI0", &PHI0, 100, 10 },
    { "PHI1", &PHI1, 150, 10 },
    { "PHI2", &PHI2, 200, 10 },

    { "ORS", &ALU_ORS, 250, 10 + 0*16 },
    { "ANDS", &ALU_ANDS, 250, 10 + 1*16 },
    { "EORS", &ALU_EORS, 250, 10 + 2*16 },
    { "SRS", &ALU_SRS, 250, 10 + 3*16 },

    { "AI0", &AI[0], 145, 116 },    { "BI0", &BI[0], 190, 116 },    // ALU input registers.
    { "AI1", &AI[1], 145, 310 },    { "BI1", &BI[1], 190, 310 },
    { "AI2", &AI[2], 145, 508 },    { "BI2", &BI[2], 190, 508 },
    { "AI3", &AI[3], 145, 698 },    { "BI3", &BI[3], 190, 698 },
    { "AI4", &AI[4], 145, 920 },    { "BI4", &BI[4], 190, 920 },
    { "AI5", &AI[5], 145, 1114 },   { "BI5", &BI[5], 190, 1114 },
    { "AI6", &AI[6], 145, 1309 },   { "BI6", &BI[6], 190, 1309 },
    { "AI7", &AI[7], 145, 1504 },   { "BI7", &BI[7], 190, 1504 },

    { "NDB/ADD", &ALU_NDB_ADD, 8, 37 + 0*16 },      // input controls
    { "DB/ADD", &ALU_DB_ADD, 8, 37 + 1*16 },
    { "ADL/ADD", &ALU_ADL_ADD, 8, 37 + 2*16 },
    { "SB/ADD", &ALU_SB_ADD, 8, 37 + 3*16 },
    { "0/ADD", &ALU_0_ADD, 8, 37 + 4*16 },

    { "ADL0", &ADL[0], 8, 128 + 0*16 }, { "SB0", &SB[0], 8, 128 + 1*16 }, { "DB0", &DB[0], 8, 128 + 2*16 }, // buses
    { "ADL1", &ADL[1], 8, 249 + 0*16 }, { "SB1", &SB[1], 8, 249 + 1*16 }, { "DB1", &DB[1], 8, 249 + 2*16 },
    { "ADL2", &ADL[2], 8, 452 + 0*16 }, { "SB2", &SB[2], 8, 452 + 1*16 }, { "DB2", &DB[2], 8, 452 + 2*16 },
    { "ADL3", &ADL[3], 8, 639 + 0*16 }, { "SB3", &SB[3], 8, 639 + 1*16 }, { "DB3", &DB[3], 8, 639 + 2*16 },
    { "ADL4", &ADL[4], 8, 859 + 0*16 }, { "SB4", &SB[4], 8, 859 + 1*16 }, { "DB4", &DB[4], 8, 859 + 2*16 },
    { "ADL5", &ADL[5], 8, 1058 + 0*16 }, { "SB5", &SB[5], 8, 1058 + 1*16 }, { "DB5", &DB[5], 8, 1058 + 2*16 },
    { "ADL6", &ADL[6], 8, 1243 + 0*16 }, { "SB6", &SB[6], 8, 1243 + 1*16 }, { "DB6", &DB[6], 8, 1243 + 2*16 },
    { "ADL7", &ADL[7], 8, 1439 + 0*16 }, { "SB7", &SB[7], 8, 1439 + 1*16 }, { "DB7", &DB[7], 8, 1439 + 2*16 },

    { "#ADD0", &ADD[0], 811, 105 },  // intermediate result
    { "#ADD1", &ADD[1], 811, 298 },
    { "#ADD2", &ADD[2], 811, 489 },
    { "#ADD3", &ADD[3], 811, 688 },
    { "#ADD4", &ADD[4], 811, 900 },
    { "#ADD5", &ADD[5], 811, 1100 },
    { "#ADD6", &ADD[6], 811, 1296 },
    { "#ADD7", &ADD[7], 811, 1491 },

};

static GraphLocator locators[] = {
};

static GraphCollector collectors[] = {
};

// Basic logic
#define BIT(n)     ( (n) & 1 )
static int NOT(int a) { return (~a & 1); }
static int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
static int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

void ALUStep ()
{
    int nand[8], nor[8], enor[8], eor[8], sums[8], carry_out;
    int BC0, BC3, BC4, BC6, DC3, DC7;

    PHI1 = NOT(PHI0);
    PHI2 = BIT(PHI0);

    if (PHI2) ALU_0_ADD = ALU_SB_ADD = ALU_DB_ADD = ALU_NDB_ADD = ALU_ADL_ADD = 0;

    for (int n=0; n<8; n++)
    {
        // inputs
        if (ALU_0_ADD) AI[n] = 0;
        else if (ALU_SB_ADD) AI[n] = SB[n];
        if (ALU_DB_ADD) BI[n] = DB[n];
        else if (ALU_NDB_ADD) BI[n] = NOT(DB[n]);
        else if (ALU_ADL_ADD) BI[n] = ADL[n];

        // logic
        nor[n] = NOR(AI[n],BI[n]);
        nand[n] = NAND(AI[n],BI[n]);

        // arithmetic + carry chain + decimal carry lookahead
        if (n&1) {
            eor[n] = NOR (NOT(nand[n]), nor[n]);
            sums[n] = NAND(eor[n],NOT(carry_out)) & NOT(NOR(eor[n],NOT(carry_out)));
            carry_out = NAND(NOT(nor[n]),carry_out) & nand[n];
        }
        else {
            enor[n] = NAND (NOT(nor[n]), nand[n]);
            sums[n] = NAND(NOT(carry_out),enor[n]) & NOT (NOR(enor[n],NOT(carry_out)));
            carry_out = NAND(carry_out,nand[n]) & NOT(nor[n]);
        }
        if (n==0) BC0 = carry_out;
        else if (n==4) BC4 = carry_out;
        else if (n==6) BC6 = carry_out;
        /*
                if (n == 3) {   // decimal half-carry look-ahead
                    if ( NOT(ALU_nDAA) ) {
                        a = NOR( NAND(NOT(nand[1]), BC0), nor[2] );
                        b = NOR(eor[3], NOT(nand[2]));
                        c = NOR(eor[1], NOT(nand[1])) & NOT(BC0) & (NOT(nand[2]) | nor[2]);
                        DC3 = a | NOR (b, c);
                    } else DC3 = 0;
                    BC3 = carry_out = carry_out & NOT(DC3);
                }
                if (n == 7) {   // decimal carry look-ahead
                    if ( NOT(ALU_nDAA) ) {
                        a = NOR( NAND(NOT(nand[5]), BC4), enor[6]);
                        b = NOR(NOT(nand[6]), eor[7]);
                        c = NOR(NOT(nand[5]), eor[5]) & NOR(BC4, NOT(enor[6]));
                        DC7 = a | NOR (b, c);
                    } else DC7 = 0;
                }
                */

        // adder hold
        if ( PHI2 ) {
            if (ALU_ORS) ADD[n] = nor[n];
            else if (ALU_ANDS) ADD[n] = nand[n];
            else if (ALU_EORS) {
                if (n&1) ADD[n] = NOT(eor[n]);
                else ADD[n] = enor[n];
            }
            else if (ALU_SRS && n) ADD[n-1] = nand[n];
            else if (ALU_SUMS) ADD[n] = sums[n];
        }
    }

    PHI0 ^= 1;
    PHI1 = NOT(PHI0);
    PHI2 = BIT(PHI0);
}

DebugContext  ALU_debug = {
    "ALU",
    "files/ALU.jpg",
    trigs,
    sizeof(trigs) / sizeof (GraphTrigger),
    locators,
    sizeof(locators) / sizeof (GraphLocator),
    collectors,
    sizeof(collectors) / sizeof(GraphCollector),
    ALUStep
};
