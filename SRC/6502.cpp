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

static  int T0, T1, TRES2;
static  int _T0, _T1X, _T2, _T3, _T4, _T5;
static  int SR_input_latch;        // extended cycle counter  input latch
static  int SRin[4], SRout[4];      // extended cycle counter shift register

static  int _ready, RDY, _PRDY, NotReady1, ReadyDelay, REST;
static  int PRDYInLatch, PRDYOutLatch, ReadyOutLatch, ReadyInLatch;

static  int ACRL1, ACRL2, ACRLOutLatch, ACRLInLatch;
static  int _SHIFT, WR, RD_DL, WRLatch, WROut;
static  int ACINLatch[4];
static  int PCLDBDelay1, PCLDBDelay2;

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

static  int CtrlOut1[CTRL_MAX], CtrlOut2[CTRL_MAX], CTRL[CTRL_MAX];

static  int BinaryCarry, DecimalCarry, AVROut;

static  int SB[8], DB[8], ADH[8], ADL[8];   // internal buses


typedef struct DECODER_LINE {
    char    *line;
    char    *name;
} DECODER_LINE;

static DECODER_LINE DECODER_ROM[130] = {     // 130 active lines.

    { "000101100000100100000", "STY_ANY" },   // 100XX100 TX     STY
    { "000000010110001000100", "ind,Y/3" },  // XXX100X1 T3     OP ind, Y
    { "000000011010001001000", "abs,Y/2" },  // XXX110X1 T2     OP abs, Y
    { "010100011001100100000", "DEY/INY_0" },  // 1X001000 T0     DEY INY
    { "010101011010100100000", "TYA_0" },  // 10011000 T0     TYA
    { "010110000001100100000", "CPY/INY_0" },  // 1100XX00 T0     CPY INY

    { "000000100010000001000", "6" },  // XXX1X1XX T2     OP zpg, X/Y & OP abs, X/Y
    { "000001000000100010000", "7" },  // 10XXXX1X TX     LDX STX A<->X S<->X
    { "000000010101001001000", "X,ind/2" },  // XXX000X1 T2     OP ind, X
    { "010101011001100010000", "TXA_0" },  // 1000101X T0     TXA
    { "010110011001100010000", "DEX_0" },  // 1100101X T0     DEX
    { "011010000001100100000", "CPX/INX_0" },  // 1110XX00 T0     CPX INX
    { "000101000000100010000", "WR_X_ANY" },  // 100XXX1X TX     STX TXA TXS
    { "010101011010100010000", "TXS_0" },  // 1001101X T0     TXS
    { "011001000000100010000", "RD_X_0" },  // 101XXX1X T0     LDX TAX TSX
    { "100110011001100010000", "DEX_1" },  // 1100101X T1     DEX
    { "101010011001100100000", "INX_1" },  // 11101000 T1     INX
    { "011001011010100010000", "TSX_0" },  // 1011101X T0     TSX
    { "100100011001100100000", "DEY/INY_1" },  // 1X001000 T1     DEY INY
    { "011001100000100100000", "LDY_0" },  // 101XX100 T0     LDY
    { "011001000001100100000", "RD_Y_0" },  // 1010XX00 T0     LDY TAY

    { "011001010101010100000", "JSR_0" },  // 00100000 T0     JSR
    { "000101010101010100001", "BRK_5" },  // 00000000 T5     BRK
    { "010100011001010100000", "Push_0" },  // 0X001000 T0     Push
    { "001010010101010100010", "RTS_4" },  // 01100000 T4     RTS
    { "001000011001010100100", "Pull_3" },  // 0X101000 T3     Pull
    { "000110010101010100001", "RTI_5" },  // 01000000 T5     RTI
    { "001010000000010010000", "ROR_ANY" },  // 011XXX1X TX     ROR
    { "000000000000000001000", "T2ANY" },  // XXXXXXXX T2     T2 ANY
    { "010110000000011000000", "EOR_0" },  // 010XXXX1 T0     EOR
    { "000010101001010100000", "JMP_ANY" },  // 01X01100 TX     JMP (excluder for C11)
    { "000000101001000001000", "ALUabs_2" },  // XXX011XX T2     ALU absolute
    { "010101000000011000000", "ORA_0" },  // 000XXXX1 T0     ORA
    { "000000000100000001000", "LEFTALL_2" },  // XXXX0XXX T2     LEFT ALL
    { "010000000000000000000", "T0ANY" },  // XXXXXXXX T0     T0 ANY
    { "000000010001010101000", "STACKOP1_2" },  // 0XX0X000 T2     BRK JSR RTI RTS Push/pull
    { "000000000001010100100", "36" },  // 0XX0XX00 T3     BRK JSR RTI RTS Push/pull + BIT JMP

    { "000001010101010100010", "BRK/JSR_4" },  // 00X00000 T4     BRK JSR
    { "000110010101010100010", "RTI_4" },  // 01000000 T4     RTI
    { "000000010101001000100", "X,ind/3" },  // XXX000X1 T3     OP X, ind
    { "000000010110001000010", "ind,Y/4" },  // XXX100X1 T4     OP ind, Y
    { "000000010110001001000", "ind,Y/2" },  // XXX100X1 T2     OP ind, Y
    { "000000001010000000100", "42" },  // XXX11XXX T3     RIGHT ODD
    { "001000011001010100000", "Pull_ANY" },  // 0X101000 TX     Pull
    { "001010000000100010000", "44" },  // 111XXX1X TX     INC NOP
    { "000000010101001000010", "X,ind/4" },  // XXX000X1 T4     OP X, ind
    { "000000010110001000100", "ind,Y/3" },  // XXX100X1 T3     OP ind, Y
    { "000010010101010100000", "RTI/RTS_ANY" },  // 01X00000 TX     RTI RTS
    { "001001010101010101000", "JSR_2" },  // 00100000 T2     JSR
    { "010010000001100100000", "49" },  // 11X0XX00 T0     CPY CPX INY INX
    { "010110000000101000000", "CMP_0" },  // 110XXXX1 T0     CMP
    { "011010000000101000000", "SBC_0" },  // 111XXXX1 T0     SBC
    { "011010000000001000000", "ADC/SBC_0" },  // X11XXXX1 T0     ADC SBC
    { "001001000000010010000", "ROL_ANY" },  // 001XXX1X TX     ROL

    { "000010101001010100100", "JMP_3" },  // 01X01100 T3     JMP
    { "000001000000010010000", "SHL_ANY" },  // 00XXXX1X TX     ASL ROL
    { "001001010101010100001", "JSR_5" },  // 00100000 T5     JSR
    { "000000010001010101000", "STACKOP2_2" },  // 0XX0X000 T2     BRK JSR RTI RTS Push/pull
    { "010101011010100100000", "TYA_0" },  // 10011000 T0     TYA
    { "100000000000011000000", "59" },  // 0XXXXXX1 T1     UPPER ODD
    { "101010000000001000000", "ADC/SBC_1" },  // X11XXXX1 T1     ADC SBC
    { "100000011001010010000", "SHIFT A_1" },  // 0XX0101X T1     ASL ROL LSR ROR
    { "010101011001100010000", "TXA_0" },  // 1000101X T0     TXA
    { "011010011001010100000", "PLA_0" },  // 01101000 T0     PLA
    { "011001000000101000000", "LDA_0" },  // 101XXXX1 T0     LDA
    { "010000000000001000000", "65" },  // XXXXXXX1 T0     ALL ODD
    { "011001011001100100000", "TAY_0" },  // 10101000 T0     TAY
    { "010000011001010010000", "SHIFT A_0" },  // 0XX0101X T0     ASL ROL LSR ROR
    { "011001011001100010000", "TAX_0" },  // 1010101X T0     TAX
    { "011001100001010100000", "BIT_0" },  // 0010X100 T0     BIT
    { "011001000000011000000", "AND_0" },  // 001XXXX1 T0     AND
    { "000000001010000000010", "71" },  // XXX11XXX T4     RIGHT ODD
    { "000000010110001000001", "ind,Y/5" },  // XXX100X1 T5     OP ind, Y

    { "010000010110000100000", "BR_0" },  // XXX10000 T0 <-  Branch + BranchReady line
    { "000110011001010101000", "PHA_2" },  // 01001000 T2     PHA
    { "010010011001010010000", "LSR/ROR_A_0" },  // 01X0101X T0     LSR ROR
    { "000010000000010010000", "LSR/ROR_ANY" },  // 01XXXX1X TX     LSR ROR
    { "000101010101010101000", "BRK_2" },  // 00000000 T2     BRK
    { "001001010101010100100", "JSR_3" },  // 00100000 T3     JSR
    { "000101000000101000000", "STA_ANY" },  // 100XXXX1 TX     STA
    { "000000010110000101000", "BR_2" },  // XXX10000 T2     Branch
    { "000000100100000001000", "zp_2" },  // XXXX01XX T2     zero page
    { "000000010100001001000", "ALU_ind_2" },  // XXXX00X1 T2     ALU indirect
    { "000000001000000001000", "abs_2" },  // XXXX1XXX T2     RIGHT ALL -G07
    { "001010010101010100001", "RTS_5" },  // 01100000 T5     RTS
    { "000000000000000000010", "T4ANY" },  // XXXXXXXX T4     T4 ANY
    { "000000000000000000100", "T3ANY" },  // XXXXXXXX T3     T3 ANY
    { "010100010101010100000", "BRK/RTI_0" },  // 0X000000 T0     BRK RTI
    { "010010101001010100000", "JMP_0" },  // 01X01100 T0     JMP
    { "000000010101001000001", "X,ind/5" },  // XXX000X1 T5     OP X, ind
    { "000000001000000000100", "90" },  // XXXX1XXX T3     RIGHT ALL -G07

    { "000000010110001000010", "ind,Y/4" },  // XXX100X1 T4     OP ind, Y
    { "000000001010000000100", "92" },  // XXX11XXX T3     RIGHT ODD
    { "000000010110000100100", "BR_3" },  // XXX10000 T3     Branch
    { "000100010101010100000", "BRK/RTI_ANY" },  // 0X000000 TX     BRK RTI
    { "001001010101010100000", "JSR_ANY" },  // 00100000 TX     JSR
    { "000010101001010100000", "JMP_ANY" },  // 01X01100 TX     JMP
//    "000000011001010100000", "Push/Pull" },  // 0XX01000 TX <-  Push/pull
    { "000101000000100000000", "STORE" },  // 100XXXXX TX     80-9F
    { "000101010101010100010", "BRK_4" },  // 00000000 T4     BRK
    { "000101011001010101000", "PHP_2" },  // 00001000 T2     PHP
    { "000100011001010101000", "Push_2" },  // 0X001000 T2     Push
    { "000010101001010100010", "JMP_4" },  // 01X01100 T4     JMP
    { "000010010101010100001", "RTI/RTS_5" },  // 01X00000 T5     RTI RTS
    { "001001010101010100001", "JSR_5" },  // 00100000 T5     JSR

    { "000110101001010101000", "JMP_2" },  // 01001100 T2     JMP
    { "001000011001010100100", "Pull_3" },  // 0X101000 T3     Pull
    { "000010000000000010000", "106" },  // X1XXXX1X TX     LSR ROR DEC INC DEX NOP (4x4 bottom right)
    { "000001000000010010000", "SHL_ANY" },  // 00XXXX1X TX     ASL ROL
    { "010010011010010100000", "CLI/SEI" },  // 01X11000 T0     CLI SEI
    { "101001100001010100000", "BIT_1" },  // 0010X100 T1     BIT
    { "010001011010010100000", "CLC/SEC" },  // 00X11000 T0     CLC SEC
    { "000000100110000000100", "Mem zp X/Y" },  // XXX101XX T3     Memory zero page X/Y
    { "101010000000001000000", "ADC/SBC_1" },  // X11XXXX1 T1     ADC SBC
    { "011001100001010100000", "BIT_0" },  // 0010X100 T0     BIT
    { "011001011001010100000", "PLP_0" },  // 00101000 T0     PLP
    { "000110010101010100010", "RTI_4" },  // 01000000 T4     RTI
    { "100110000000101000000", "CMP_1" },  // 110XXXX1 T1     CMP
    { "100010101001100100000", "CPXY_abs_1" },  // 11X01100 T1     CPY CPX abs
    { "100001011001010010000", "ASL/ROL_A_1" },  // 00X0101X T1     ASL ROL
    { "100010000101100100000", "CPXY_immzp_1" },  // 11X00X00 T1     CPY CPX zpg/immed

//    "000000011001010100000", "Push/Pull" },  // 0XX01000 TX
    { "010010011010100100000", "CLD/SED" },  // 11X11000 T0     CLD SED
    { "000001000000000000000", "BB6" },  // X0XXXXXX TX     Branch bit 6
    { "000000101001000000100", "Mem abs." },  // XXX011XX T3     Memory absolute
    { "000000100101000001000", "Mem zp" },  // XXX001XX T2     Memory zero page
    { "000000010100001000001", "Mem ind" },  // XXXX00X1 T5     Memory indirect
    { "000000001010000000010", "Mem abs X/Y" },  // XXX11XXX T4     Memory absolute X/Y
    { "000000000000010000000", "BB7" },  // 0XXXXXXX TX     Branch bit 7
    { "001001011010100100000", "CLV" },  // 10111000 TX     CLV
    { "000000011000000......", "impl" },  // XXXX10X0 TX     All implied, except Push/pull
    { "000000011001010100000", "Push/Pull" },  // 0XX01000 TX <-  Push/pull (occure 2 times, see above)

};

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
        CTRL[DB_P] = NOR ( CtrlOut2[DB_P], _ready );
        CTRL[IR5_I] = NOT ( CtrlOut2[IR5_I] );
        CTRL[IR5_C] = NOT ( CtrlOut2[IR5_C] );
        CTRL[DB_C] = NOT ( CtrlOut2[DB_C] );
        CTRL[ACR_C] = NOT ( CtrlOut2[ACR_C] );
        CTRL[IR5_D] = NOT ( CtrlOut2[IR5_D] );
        CTRL[DBZ_Z] = NOT ( CtrlOut2[DBZ_Z] );
        CTRL[AVR_V] = CtrlOut2[AVR_V];
        CTRL[ONE_V] = CtrlOut2[ONE_V];
        CTRL[ZERO_V] = NOT (CtrlOut2[ZERO_V]);
        CTRL[DB_V] = NAND (CtrlOut2[DB_P], CtrlOut2[DB_V]);
        CTRL[AVR_V] = CtrlOut2[AVR_V];
        CTRL[DB_N] = NAND (CtrlOut2[DBZ_Z], CtrlOut2[DB_P]) & NOT (CtrlOut2[DB_N]);
        CTRL[P_DB] = NOT ( CtrlOut2[P_DB] );

        // bottom part commands.
        CTRL[ADH_ABH] = NOT ( CtrlOut2[ADH_ABH] );      // bus control
        CTRL[ADL_ABL] = NOT ( CtrlOut2[ADL_ABL] );
        CTRL[ZERO_ADL0] = NOT ( CtrlOut2[ZERO_ADL0] );
        CTRL[ZERO_ADL1] = NOT ( CtrlOut2[ZERO_ADL1] );
        CTRL[ZERO_ADL2] = NOT ( CtrlOut2[ZERO_ADL2] );
        CTRL[ZERO_ADH0] = NOT ( CtrlOut2[ZERO_ADH0] );
        CTRL[ZERO_ADH17] = NOT ( CtrlOut2[ZERO_ADH17] );
        CTRL[SB_DB] = NOT ( CtrlOut2[SB_DB] );
        CTRL[SB_AC] = NOT ( CtrlOut2[SB_AC] );
        CTRL[SB_ADH] = NOT ( CtrlOut2[SB_ADH] );
        CTRL[Y_SB] = NOT ( CtrlOut2[Y_SB] );            // regs contols
        CTRL[X_SB] = NOT ( CtrlOut2[X_SB] );
        CTRL[SB_Y] = NOT ( CtrlOut2[SB_Y] );
        CTRL[SB_X] = NOT ( CtrlOut2[SB_X] );
        CTRL[S_SB] = NOT ( CtrlOut2[S_SB] );
        CTRL[S_ADL] = NOT ( CtrlOut2[S_ADL] );
        CTRL[SB_S] = NOT ( CtrlOut2[SB_S] );
        CTRL[S_S] = NOT ( CtrlOut2[S_S] );
        CTRL[NDB_ADD] = NOT ( CtrlOut2[NDB_ADD] );      // ALU controls
        CTRL[DB_ADD] = NOT ( CtrlOut2[DB_ADD] );
        CTRL[ZERO_ADD] = NOT ( CtrlOut2[ZERO_ADD] );
        CTRL[SB_ADD] = NOT ( CtrlOut2[SB_ADD] );
        CTRL[ADL_ADD] = NOT ( CtrlOut2[ADL_ADD] );
        CtrlOut1[ANDS] = NOT ( CtrlOut2[ANDS] );
        CTRL[ANDS] = NOT ( CtrlOut1[ANDS] );
        CtrlOut1[EORS] = NOT ( CtrlOut2[EORS] );
        CTRL[EORS] = NOT ( CtrlOut1[EORS] );
        CtrlOut1[ORS] = NOT ( CtrlOut2[ORS] );
        CTRL[ORS] = NOT ( CtrlOut1[ORS] );
        CtrlOut1[SRS] = NOT ( CtrlOut2[SRS] );
        CTRL[SRS] = NOT ( CtrlOut1[SRS] );
        CtrlOut1[SUMS] = NOT ( CtrlOut2[SUMS] );
        CTRL[SUMS] = NOT ( CtrlOut1[SUMS] );
        CtrlOut1[_ACIN] = CTRL[_ACIN] = NOT ( ACINLatch[0] | ACINLatch[1] | ACINLatch[2] | ACINLatch[3] );
        CtrlOut1[_DAA] = NOT ( CtrlOut2[_DAA] );
        CTRL[_DAA] = NOT ( CtrlOut1[_DAA] );
        CtrlOut1[_DSA] = NOT ( CtrlOut2[_DSA] );
        CTRL[_DSA] = NOT ( CtrlOut1[_DSA] );
        CTRL[ADD_SB06] = NOT ( CtrlOut2[ADD_SB06] );
        CTRL[ADD_SB7] = NOT ( CtrlOut2[ADD_SB7] );
        CTRL[ADD_ADL] = NOT ( CtrlOut2[ADD_ADL] );
        CTRL[AC_SB] = NOT ( CtrlOut2[AC_SB] );
        CTRL[AC_DB] = NOT ( CtrlOut2[AC_DB] );
        CTRL[ADH_PCH] = NOT ( CtrlOut2[ADH_PCH] );      // PC controls
        CTRL[PCH_PCH] = NOT ( CtrlOut2[PCH_PCH] );
        CTRL[PCH_DB] = NOT ( CtrlOut2[PCH_DB] );
        CTRL[PCL_DB] = NOT ( CtrlOut2[PCL_DB] );
        CTRL[PCH_ADH] = NOT ( CtrlOut2[PCH_ADH] );
        CTRL[PCL_PCL] = NOT ( CtrlOut2[PCL_PCL] );
        CTRL[PCL_ADL] = NOT ( CtrlOut2[PCL_ADL] );
        CTRL[ADL_PCL] = NOT ( CtrlOut2[ADL_PCL] );
        CTRL[DL_ADL] = NOT ( CtrlOut2[DL_ADL] );        // data latch controls
        CTRL[DL_ADH] = NOT ( CtrlOut2[DL_ADH] );
        CTRL[DL_DB] = NOT ( CtrlOut2[DL_DB] );

        // miscellaneous random logic
        PCLDBDelay1 = NOR ( _ready, PCLDBDelay2 );
    }

    if (PHI2)
    {
        int DL_PCH;

        // decoder
        #define IR(n)  ( NOT (_IR[n]) )
        #define nIR(n) ( _IR[n] )
        int PushPull = NOT ( IR(2) | nIR(3) | IR(4) | IR(7) | IR01 );
        for (n=0; n<128; n++) {
            int out = 1;
            char * line = DECODER_ROM[n].line;

            if ( _T1X && line[0] == '1' ) out = 0;
            else if ( _T0 && line[1] == '1' ) out = 0;

            else if ( nIR(5) && line[2] == '1' ) out = 0;
            else if ( IR(5) && line[3] == '1' ) out = 0;
            else if ( nIR(6) && line[4] == '1' ) out = 0;
            else if ( IR(6) && line[5] == '1' ) out = 0;
            else if ( nIR(2) && line[6] == '1' ) out = 0;
            else if ( IR(2) && line[7] == '1' ) out = 0;
            else if ( nIR(3) && line[8] == '1' ) out = 0;
            else if ( IR(3) && line[9] == '1' ) out = 0;
            else if ( nIR(4) && line[10] == '1' ) out = 0;
            else if ( IR(4) && line[11] == '1' ) out = 0;
            else if ( nIR(7) && line[12] == '1' ) out = 0;
            else if ( IR(7) && line[13] == '1' ) out = 0;

            else if ( nIR(0) && line[14] == '1' ) out = 0;
            else if ( IR01 && line[15] == '1' ) out = 0;
            else if ( nIR(1) && line[16] == '1' ) out = 0;

            else if ( _T2 && line[17] == '1' ) out = 0;
            else if ( _T3 && line[18] == '1' ) out = 0;
            else if ( _T4 && line[19] == '1' ) out = 0;
            else if ( _T5 && line[20] == '1' ) out = 0;

            // Line 73 has additional cutout by NotPrevReady
            if ( n == 73 && _PRDY ) out = 0;

            // Lines 83 and 90 are special with PushPull excluder
            if ( (n == 83 || n == 90) && PushPull ) out = 0;

            DECODER[n] = out;
        }
        // This line is special (all implied, except push/pull)
        DECODER[n] = NOT ( IR(2) | nIR(3) | IR(0) | PushPull );
        DECODER[129] = PushPull;

        /*
         * Various random logic circuits (active only during PHI2)
         *
         */

        // PC control
        CtrlOut2[PCH_DB] = PCLDBDelay2 = NOR (DECODER[77], DECODER[78]);
        CtrlOut2[PCL_DB] = NOT (PCLDBDelay1);
        CtrlOut2[ADH_PCH] = NOT ( DECODER[83] | DECODER[84] | DECODER[93] | DECODER[80] | T0 | T1 );
        CtrlOut2[PCH_PCH] = NOT ( CtrlOut2[ADH_PCH] );
        int JB = NOT ( DECODER[94] | DECODER[95] | DECODER[96] );
        DL_PCH = NOR (JB, NOT(T0));
        CtrlOut2[PCL_ADL] = NOT ( NOR(NOT(T0), NOR(NotReady1, JB)) | DECODER[56] | DECODER[80] | T1 | DECODER[83] );
        CtrlOut2[PCH_ADH] = NOR ( NOT(CtrlOut2[PCL_ADL] | DECODER[73] | DL_PCH), DECODER[93] );
        CtrlOut2[ADL_PCL] = NAND (NOT(NotReady1), DECODER[93]) & NOT (DECODER[84] | NOT(CtrlOut2[PCL_ADL]) | T0 );
        CtrlOut2[PCL_PCL] = NOT (CtrlOut2[ADL_PCL]);
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
