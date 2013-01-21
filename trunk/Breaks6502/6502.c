// MOS 6502 clock-accurate emulator.
#include "6502.h"
#include <stdio.h>

// Global quickies.
#define DATA_RD(n) (BIT(cpu->pad[M6502_PAD_DATA] >> n))
#define DATA_WR(n,b) (cpu->pad[M6502_PAD_DATA] = (cpu->pad[M6502_PAD_DATA] & ~(1 << (n))) | ((b) << (n)) )
#define ADDR_WR(n,b) (cpu->pad[M6502_PAD_ADDR] = (cpu->pad[M6502_PAD_ADDR] & ~(1 << (n))) | ((b) << (n)) )
#define PD(n)   (cpu->reg[M6502_REG_PD][n])
#define nPD(n)   (NOT(cpu->reg[M6502_REG_PD][n]))
#define IR(n)   (cpu->reg[M6502_REG_IR][n])
#define nIR(n)   (NOT(cpu->reg[M6502_REG_IR][n]))
#define PHI1    (cpu->pad[M6502_PAD_PHI1])
#define PHI2    (cpu->pad[M6502_PAD_PHI2])
#define nREADY    (cpu->ctrl[M6502_CTRL_nREADY])
#define PLA(n)   (cpu->bus[M6502_BUS_PLA][n])
#define SB(n)   (cpu->bus[M6502_BUS_SB][n])
#define DB(n)   (cpu->bus[M6502_BUS_DB][n])
#define ADH(n)   (cpu->bus[M6502_BUS_ADH][n])
#define ADL(n)   (cpu->bus[M6502_BUS_ADL][n])
#define Y(n)   (cpu->reg[M6502_REG_Y][n])
#define X(n)   (cpu->reg[M6502_REG_X][n])
#define S(n)   (cpu->reg[M6502_REG_S][n])
#define AI(n)   (cpu->reg[M6502_REG_AI][n])
#define BI(n)   (cpu->reg[M6502_REG_BI][n])
#define ADD(n)   (cpu->reg[M6502_REG_ADD][n])
#define AC(n)   (cpu->reg[M6502_REG_AC][n])
#define ABH(n)   (cpu->reg[M6502_REG_ABH][n])
#define ABL(n)   (cpu->reg[M6502_REG_ABL][n])
#define DOR(n)   (cpu->reg[M6502_REG_DOR][n])
#define DL(n)   (cpu->reg[M6502_REG_DL][n])

// ------------------------------------------------------------------------

// Basic logic
#define BIT(n)     ( (n) & 1 )
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

// Flip/flop
#define FF(ff,out,r,s)  \
    out = NOR(ff, s);   \
    ff = NOR(out, r);

unsigned long packreg ( char *reg, int bits )
{
    unsigned long val = 0, i;
    for (i=0; i<bits; i++) {
        if (reg[i]) val |= (1 << i);
    }
    return val;
} 

void unpackreg (char *reg, unsigned char val, int bits)
{
    int i;
    for (i=0; i<bits; i++) {
        reg[i] = (val >> i) & 1;
    }
}

// ------------------------------------------------------------------------
// TOP PART

// Clock -> Data bus -> Predecode -> Pads -> Ready -> Cycle counter -> PLA -> Random logic -> Instruction register

// Return instruction name and operands, without operands decoding.
static char *inames[] = {
 "BRK",     "ORA X,ind", "??? ---", "??? ---", "??? ---",   "ORA zpg  ", "ASL zpg  ", "??? ---", "PHP", "ORA #    ", "ASL A  ", "??? ---", "??? ---",   "ORA abs  ", "ASL abs  ", "??? ---",
 "BPL rel", "ORA ind,Y", "??? ---", "??? ---", "??? ---",   "ORA zpg,X", "ASL zpg,X", "??? ---", "CLC", "ORA abs,Y", "??? ---", "??? ---", "??? ---",   "ORA abs,X", "ASL abs,X", "??? ---",
 "JSR abs", "AND X,ind", "??? ---", "??? ---", "BIT zpg",   "AND zpg  ", "ROL zpg  ", "??? ---", "PLP", "AND #    ", "ROL A  ", "??? ---", "BIT abs",   "AND abs  ", "ROL abs  ", "??? ---",
 "BMI rel", "AND ind,Y", "??? ---", "??? ---", "??? ---",   "AND zpg,X", "ROL zpg,X", "??? ---", "SEC", "AND abs,Y", "??? ---", "??? ---", "??? ---",   "AND abs,X", "ROL abs,X", "??? ---",
 "RTI",     "EOR X,ind", "??? ---", "??? ---", "??? ---",   "EOR zpg  ", "LSR zpg  ", "??? ---", "PHA", "EOR #    ", "LSR A  ", "??? ---", "JMP abs",   "EOR abs  ", "LSR abs  ", "??? ---",
 "BVC rel", "EOR ind,Y", "??? ---", "??? ---", "??? ---",   "EOR zpg,X", "LSR zpg,X", "??? ---", "CLI", "EOR abs,Y", "??? ---", "??? ---", "??? ---",   "EOR abs,X", "LSR abs,X", "??? ---",
 "RTS",     "ADC X,ind", "??? ---", "??? ---", "??? ---",   "ADC zpg  ", "ROR zpg  ", "??? ---", "PLA", "ADC #    ", "ROR A  ", "??? ---", "JMP ind",   "ADC abs  ", "ROR abs  ", "??? ---",
 "BVS rel", "ADC ind,Y", "??? ---", "??? ---", "??? ---",   "ADC zpg,X", "ROR zpg,X", "??? ---", "SEI", "ADC abs,Y", "??? ---", "??? ---", "??? ---",   "ADC abs,X", "ROR abs,X", "??? ---",
 "??? ---", "STA X,ind", "??? ---", "??? ---", "STY zpg",   "STA zpg  ", "STX zpg  ", "??? ---", "DEY", "??? ---  ", "TXA    ", "??? ---", "STY abs",   "STA abs  ", "STX abs  ", "??? ---",
 "BCC rel", "STA ind,Y", "??? ---", "??? ---", "STY zpg,X", "STA zpg,X", "STX zpg,Y", "??? ---", "TYA", "STA abs,Y", "TXS    ", "??? ---", "??? ---",   "STA abs,X", "??? ---  ", "??? ---",
 "LDY #",   "LDA X,ind", "LDX #",   "??? ---", "LDY zpg",   "LDA zpg  ", "LDX zpg  ", "??? ---", "TAY", "LDA #    ", "TAX    ", "??? ---", "LDY abs",   "LDA abs  ", "LDX abs  ", "??? ---",
 "BCS rel", "LDA ind,Y", "??? ---", "??? ---", "LDY zpg,X", "LDA zpg,X", "LDX zpg,Y", "??? ---", "CLV", "LDA abs,Y", "TSX    ", "??? ---", "LDY abs,X", "LDA abs,X", "LDX abs,Y", "??? ---",
 "CPY #",   "CMP X,ind", "??? ---", "??? ---", "CPY zpg",   "CMP zpg  ", "DEC zpg  ", "??? ---", "INY", "CMP #    ", "DEX    ", "??? ---", "CPY abs",   "CMP abs  ", "DEC abs  ", "??? ---",
 "BNE rel", "CMP ind,Y", "??? ---", "??? ---", "??? ---",   "CMP zpg,X", "DEC zpg,X", "??? ---", "CLD", "CMP abs,Y", "??? ---", "??? ---", "??? ---",   "CMP abs,X", "DEC abs,X", "??? ---",
 "CPX #",   "SBC X,ind", "??? ---", "??? ---", "CPX zpg",   "SBC zpg  ", "INC zpg  ", "??? ---", "INX", "SBC #    ", "NOP    ", "??? ---", "CPX abs",   "SBC abs  ", "INC abs  ", "??? ---",
 "BEQ rel", "SBC ind,Y", "??? ---", "??? ---", "??? ---",   "SBC zpg,X", "INC zpg,X", "??? ---", "SED", "SBC abs,Y", "??? ---", "??? ---", "??? ---",   "SBC abs,X", "INC abs,X", "??? ---",
};

typedef struct PLA_ENTRY {
    char    *line;
    char    *name;
} PLA_ENTRY;

static PLA_ENTRY PLA_ROM[129] = {     // 129 active lines.

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
//    "000000011001010100000", "0" },  // 0XX01000 TX <-  Push/pull, F11 & F18 excluder
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

//    "000000011001010100000", "0" },  // 0XX01000 TX     Not actually line. Controls last line to exlude push/pull opcodes --->
    { "010010011010100100000", "CLD/SED" },  // 11X11000 T0     CLD SED
    { "000001000000000000000", "BB6" },  // X0XXXXXX TX     Branch bit 6
    { "000000101001000000100", "Mem abs." },  // XXX011XX T3     Memory absolute
    { "000000100101000001000", "Mem zp" },  // XXX001XX T2     Memory zero page
    { "000000010100001000001", "Mem ind" },  // XXXX00X1 T5     Memory indirect
    { "000000001010000000010", "Mem abs X/Y" },  // XXX11XXX T4     Memory absolute X/Y
    { "000000000000010000000", "BB7" },  // 0XXXXXXX TX     Branch bit 7
    { "001001011010100100000", "CLV" },  // 10111000 TX     CLV
    { "000000011000000......", "impl" },  // XXXX10X0 TX     All implied, except Push/pull

};

// random logic outputs names
static char *RANDOM_OUT[] = {
    "ADH/ABH", "ADL/ABL", "Y/SB", "X/SB", "0/ADL0", "0/ADL1", "0/ADL2", "SB/Y", "SB/X", "S/SB", "S/ADL", "SB/S", "S/S", 
    "nDB/ADD", "DB/ADD", "0/ADD", "SB/ADD", "ADL/ADD", "ANDS", "EORS", "ORS", "I/ADDC", "SRS", "SUMS", "DAA", "ADD/SB7", "ADD/SB06", "ADD/ADL", "DSA", "AVR", "ACR",
    "0/ADH0", "SB/DB", "SB/AC", "SB/ADH", "0/ADH17", "AC/SB", "AC/DB", 
    "ADH/PCH", "PCH/PCH", "PCH/DB", "PCL/DB", "PCH/ADH", "PCL/PCL", "PCL/ADL", "ADL/PCL", "IPC",
    "DL/ADL", "DL/ADH", "DL/DB", "P/DB", "DBZ",
};

static void CLOCK (ContextM6502 *cpu)
{
    PHI2 = BIT(cpu->pad[M6502_PAD_PHI0]);   // read-mode
    PHI1 = NOT(PHI2);       // write-mode
    if (cpu->debug[M6502_DEBUG_OUT]) {
        if (PHI1) printf ("PHI1 ");
        if (PHI2) printf ("PHI2 ");
    }
}

// /INT, /NMI, /RES pads
// once signal is asserted its locked on RS-flip/flop.
static void PADS (ContextM6502 *cpu)
{
    int ff;

    FF (cpu->latch[M6502_FF_NMI], ff, NAND(NOT(cpu->pad[M6502_PAD_nNMI]),PHI2), NAND(cpu->pad[M6502_PAD_nNMI],PHI2));
    cpu->ctrl[M6502_CTRL_NMI] = NOT(ff);

    FF (cpu->latch[M6502_FF_IRQ], ff, NAND(NOT(cpu->pad[M6502_PAD_nIRQ]),PHI2), NAND(cpu->pad[M6502_PAD_nIRQ],PHI2));
    if (PHI1) cpu->latch[M6502_LATCH_IRQ] = ff;
    cpu->ctrl[M6502_CTRL_IRQ] = NOT(cpu->latch[M6502_LATCH_IRQ]);

    FF (cpu->latch[M6502_FF_RES], ff, NAND(NOT(cpu->pad[M6502_PAD_nRES]),PHI2), NAND(cpu->pad[M6502_PAD_nRES],PHI2));
    if (PHI1) cpu->latch[M6502_LATCH_RES] = ff;
    cpu->ctrl[M6502_CTRL_RES] = NOT(cpu->latch[M6502_LATCH_RES]);

    if (cpu->debug[M6502_DEBUG_OUT]) {
        printf ("INT:%i%i%i ", cpu->ctrl[M6502_CTRL_NMI], cpu->ctrl[M6502_CTRL_IRQ], cpu->ctrl[M6502_CTRL_RES]);
    }
}

static void READY_CONTROL (ContextM6502 *cpu)
{
    if (PHI2) cpu->latch[M6502_LATCH_BRDY_IN] = NOT(cpu->pad[M6502_PAD_RDY]);
    if (PHI1) cpu->latch[M6502_LATCH_BRDY_OUT] = NOT(cpu->latch[M6502_LATCH_BRDY_IN]);
    cpu->ctrl[M6502_CTRL_nBRDY] = NOT (cpu->latch[M6502_LATCH_BRDY_OUT]);

    if (PHI2) cpu->latch[M6502_LATCH_nRDY] = NOR (cpu->pad[M6502_PAD_RDY], cpu->latch[M6502_LATCH_RWRDY]);
    nREADY = cpu->latch[M6502_LATCH_nRDY];
    if (cpu->debug[M6502_DEBUG_OUT])  {
        if (NOT(nREADY)) printf ("RDY ");
    }
}

static void CYCLE_COUNTER (ContextM6502 *cpu)
{
    int i, c, in, out, res, sync = NOT(cpu->latch[M6502_LATCH_SYNC]);
    int tres = NOT(cpu->latch[M6502_LATCH_TRES]);

    // COUNTER 0/1
    if (PHI1) cpu->latch[M6502_LATCH_nTWOCYCLE] = cpu->ctrl[M6502_CTRL_nTWOCYCLE];
    c = NAND( cpu->latch[M6502_LATCH_TR], cpu->latch[M6502_LATCH_nTWOCYCLE]) & NOT(cpu->latch[M6502_LATCH_TQ]);
    cpu->ctrl[M6502_CTRL_nT1] = NOR (cpu->latch[M6502_LATCH_TIN], cpu->latch[M6502_LATCH_TOUT]);
    in = NOR (cpu->ctrl[M6502_CTRL_nT1] , c );
    cpu->ctrl[M6502_CTRL_T1] = NOT(in);
    if (PHI2) cpu->latch[M6502_LATCH_TIN] = in;
    if (PHI1) cpu->latch[M6502_LATCH_TOUT] = NOR(nREADY, cpu->latch[M6502_LATCH_TIN]);
    cpu->ctrl[M6502_CTRL_nT0] = NOT(cpu->latch[M6502_LATCH_TOUT]);

    // COUNTER 2-5 (shift register)
    if (PHI2) cpu->latch[M6502_LATCH_SYNCTR] = sync;
    out = NOT(cpu->latch[M6502_LATCH_SYNCTR]);
    for (i=0; i<4; i++)
    {
        if ( PHI1 ) {
            if (nREADY) cpu->reg[M6502_REG_TRIN][i] = out;
            else cpu->reg[M6502_REG_TRIN][i] = NOT(cpu->reg[M6502_REG_TROUT][i]);
        }
        res = NAND( NOT(cpu->reg[M6502_REG_TRIN][i]), NOT(tres) );
        switch (i)
        {
            case 0: cpu->ctrl[M6502_CTRL_nT2] = res; break;
            case 1: cpu->ctrl[M6502_CTRL_nT3] = res; break;
            case 2: cpu->ctrl[M6502_CTRL_nT4] = res; break;
            case 3: cpu->ctrl[M6502_CTRL_nT5] = res; break;
        }
        if ( PHI2 ) cpu->reg[M6502_REG_TROUT][i] = NOT(res);
        out = NOT(cpu->reg[M6502_REG_TROUT][i]);
    }
}

// predecode logic
// Two-cycles instructions are all implied (except push/pull) + ALU ops with #immed operand.
static void PREDECODE (ContextM6502 *cpu)
{
    int b, p[4];
    if ( PHI2 ) {
        for (b=0; b<8; b++) PD(b) = DATA_RD(b);
    }

    // Determine whenever instruction takes 2 cycle / implied.
    p[0] = NOT ( PD(2) | nPD(3) | PD(4) | nPD(0) );     // XXX010X1
    p[1] = NOT ( PD(2) | nPD(3) | PD(0) );      // XXXX10X0
    p[2] = NOT ( PD(4) | PD(7) | PD(1) );       // 0XX0XX0X
    p[3] = NOT ( PD(2) | PD(3) | PD(4) | nPD(7) | PD(0) );  // 1XX000X0
    cpu->ctrl[M6502_CTRL_nTWOCYCLE] = NOT ( p[0] | p[3] | (NOT(p[2]) & p[1]) );
    cpu->ctrl[M6502_CTRL_nIMPLIED] = NOT ( p[1] );
}

static void dump_pla (ContextM6502 *cpu)
{
    int n, ir;

    // dump IR/TR.
    ir = packreg (cpu->reg[M6502_REG_IR], 8);
    printf ("IR:%02X %s ", ir, inames[ir] );
    if (NOT(cpu->ctrl[M6502_CTRL_nT0])) printf ("T0X");
    else if (NOT(cpu->ctrl[M6502_CTRL_nT1])) printf ("T1 ");
    else if (NOT(cpu->ctrl[M6502_CTRL_nT2])) printf ("T2 ");
    else if (NOT(cpu->ctrl[M6502_CTRL_nT3])) printf ("T3 ");
    else if (NOT(cpu->ctrl[M6502_CTRL_nT4])) printf ("T4 ");
    else if (NOT(cpu->ctrl[M6502_CTRL_nT5])) printf ("T5 ");
    else printf ("T0 ");
    printf ( "| " );

    // dump pla outputs.
    for (n=0; n<129; n++) {
        if ( cpu->bus[M6502_BUS_PLA][n] ) printf ( "%s(%i), ", PLA_ROM[n].name, n );
    }
    printf ("\n");
}

static void PLA_DECODE (ContextM6502 *cpu)
{
    int n, out, PushPull, IR01;
    char * line;

    IR01 = IR(0) | IR(1);
    PushPull = NOT ( IR(2) | nIR(3) | IR(4) | IR(7) | IR01 );

    for (n=0; n<128; n++) {
        out = 1;
        line = PLA_ROM[n].line;

        if ( cpu->ctrl[M6502_CTRL_nT1] && line[0] == '1' ) out = 0;
        else if ( cpu->ctrl[M6502_CTRL_nT0] && line[1] == '1' ) out = 0;

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

        else if ( cpu->ctrl[M6502_CTRL_nT2] && line[17] == '1' ) out = 0;
        else if ( cpu->ctrl[M6502_CTRL_nT3] && line[18] == '1' ) out = 0;
        else if ( cpu->ctrl[M6502_CTRL_nT4] && line[19] == '1' ) out = 0;
        else if ( cpu->ctrl[M6502_CTRL_nT5] && line[20] == '1' ) out = 0;

        // Line 73 has additional cutout by BranchNotReady
        else if ( n == 73 && cpu->ctrl[M6502_CTRL_nBRDY] ) out = 0;

        // Lines 83 and 90 are special with PushPull excluder
        else if ( (n == 83 || n == 90) && PushPull ) out = 0;

        cpu->bus[M6502_BUS_PLA][n] = out;
    }

    // Last line is special (all implied, except push/pull)
    cpu->bus[M6502_BUS_PLA][n] = NOT ( IR(2) | nIR(3) | IR(0) | PushPull );

    if (cpu->debug[M6502_DEBUG_OUT]) dump_pla (cpu);
}

// interrupt detection
static void INTERRUPTS (ContextM6502 *cpu)
{
    int brke = NOR (NOT(PLA(22)), nREADY);
    int p = NOT (cpu->latch[M6502_LATCH_NMI_IN] | cpu->latch[M6502_LATCH_NMIG] | cpu->latch[M6502_LATCH_INTDELAY2]);
    cpu->ctrl[M6502_CTRL_NMIG] = NOR(cpu->latch[M6502_LATCH_NMIG_OUT], NOR(cpu->latch[M6502_LATCH_BRKDONE_OUT], cpu->latch[M6502_LATCH_BRKDONE]));
    cpu->ctrl[M6502_CTRL_BRKDONE] = NOR (NOT(cpu->latch[M6502_LATCH_BRKDONE_IN]), nREADY);
    cpu->ctrl[M6502_CTRL_VEC] = NOR ( NOT(cpu->latch[M6502_LATCH_BRKE_OUT]), brke);

    if (PHI1)
    {
        cpu->latch[M6502_LATCH_NMI_IN] = cpu->ctrl[M6502_CTRL_NMI];
        cpu->latch[M6502_LATCH_NMIG_OUT] = NOR(cpu->ctrl[M6502_CTRL_NMI], NOT(cpu->latch[M6502_LATCH_VEC_OUT])) & NOT(p);
        cpu->latch[M6502_LATCH_INTDELAY2] = NOT(cpu->latch[M6502_LATCH_INTDELAY1]);
        if( nREADY) cpu->latch[M6502_LATCH_BRKE_OUT] &= NOT(cpu->latch[M6502_LATCH_BRKE_IN]);
        else cpu->latch[M6502_LATCH_BRKE_OUT] = NOT(cpu->latch[M6502_LATCH_BRKE_IN]);
        cpu->latch[M6502_LATCH_BRKDONE_OUT] = cpu->ctrl[M6502_CTRL_BRKDONE];
    }

    if (PHI2)
    {
        cpu->latch[M6502_LATCH_NMIG] = p;
        cpu->latch[M6502_LATCH_BRKDONE] = cpu->latch[M6502_LATCH_INTDELAY1] = cpu->ctrl[M6502_CTRL_NMIG];
        cpu->latch[M6502_LATCH_BRKE_IN] = brke;
        cpu->latch[M6502_LATCH_VEC_OUT] = cpu->ctrl[M6502_CTRL_VEC];
        cpu->latch[M6502_LATCH_BRKDONE_IN] = NOT(cpu->latch[M6502_LATCH_BRKE_OUT]);
    }

    if (cpu->debug[M6502_DEBUG_OUT]) {
        printf ( "BRKDONE:%i ", cpu->ctrl[M6502_CTRL_BRKDONE]);
        printf ( "VEC:%i ", cpu->ctrl[M6502_CTRL_VEC]);
    }
}

static void dump_random (ContextM6502 *cpu)
{
    int n;

    // flags
    if (cpu->ctrl[M6502_CTRL_N_OUT]) printf ("N"); else printf ("n");
    if (cpu->ctrl[M6502_CTRL_V_OUT]) printf ("V"); else printf ("v");
    printf ("-");
    if (cpu->ctrl[M6502_CTRL_B_OUT]) printf ("B"); else printf ("b");
    if (cpu->ctrl[M6502_CTRL_D_OUT]) printf ("D"); else printf ("d");
    if (cpu->ctrl[M6502_CTRL_I_OUT]) printf ("I"); else printf ("i");
    if (cpu->ctrl[M6502_CTRL_Z_OUT]) printf ("Z"); else printf ("z");
    if (cpu->ctrl[M6502_CTRL_C_OUT]) printf ("C"); else printf ("c");
    printf ( " ");

    // other important things
    printf ("(");
    if (cpu->ctrl[M6502_CTRL_BRTAKEN]) printf ("BRTAKEN ");
    printf (")");

    // random logic output lines.
    printf ("| ");
    for (n=0; n<=50; n++) {
        if (cpu->bus[M6502_BUS_RANDOM][n]) printf ( "%s ", RANDOM_OUT[n]);
    }
    printf ("\n");
}

static void RANDOM_LOGIC (ContextM6502 *cpu)
{
    int ARIT, MEMOP, STOR, BR2, RD, SBAC, LOG1, ANDS, SRS, IND, JB, PCHDB, PCLDB, PCDB, ADHPCH, PCHPCH, PCLADL, ADLPCL;
    int sync, bb6, bb7, res, p;

    // flags out
    cpu->ctrl[M6502_CTRL_I_OUT] = NOT(cpu->latch[M6502_LATCH_IFLAG_OUT]);
    cpu->ctrl[M6502_CTRL_N_OUT] = NOT(cpu->latch[M6502_LATCH_NFLAG_OUT]);
    cpu->ctrl[M6502_CTRL_V_OUT] = NOT(cpu->latch[M6502_LATCH_VFLAG_OUT]);
    cpu->ctrl[M6502_CTRL_D_OUT] = NOT(cpu->latch[M6502_LATCH_DFLAG_OUT]);
//    cpu->ctrl[M6502_CTRL_B_OUT]
//    cpu->ctrl[M6502_CTRL_C_OUT]
//    cpu->ctrl[M6502_CTRL_Z_OUT]

    // interconnections.
    MEMOP = NOT ( PLA(111) | PLA(122) | PLA(123) | PLA(124) | PLA(125) );
    STOR = NOR(PLA(97), MEMOP);
    ARIT = NOT ( PLA(112) | PLA(116) | PLA(117) | PLA(118) | PLA(119));
    BR2 = PLA(80);
    ANDS = PLA(69) | PLA(70);
    IND = NOT ( PLA(84) | PLA(89) | PLA(90) | PLA(91) );

    // SB/AC
    SBAC = NOT ( PLA(58) | PLA(59) | PLA(60) | PLA(61) | PLA(62) | PLA(63) | PLA(64) );
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_SB_AC] = SBAC;
    cpu->bus[M6502_BUS_RANDOM][M6502_SB_AC] = NOR(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_SB_AC], PHI2) & NOT(PHI2);

    // SB/Y SB/X S/SB

    // shift/rotate
    cpu->ctrl[M6502_CTRL_SH_R] = NOT (cpu->latch[M6502_LATCH_SHR_OUT]);
    cpu->ctrl[M6502_CTRL_ASRL] = cpu->latch[M6502_LATCH_ASRL_OUT];
    if ( cpu->ctrl[M6502_CTRL_ASRL] & PLA(107) ) ARIT = 0;
    cpu->ctrl[M6502_CTRL_nSHIFT] = NOR (PLA(106), PLA(107));
    if (PHI1) {
        if (nREADY) cpu->latch[M6502_LATCH_SHR_OUT] = NOR (cpu->latch[M6502_LATCH_SHR_IN], cpu->latch[M6502_LATCH_SHIFT_IN]);
        else cpu->latch[M6502_LATCH_SHR_OUT] = NOT(cpu->latch[M6502_LATCH_SHIFT_IN]);
        cpu->latch[M6502_LATCH_ASRL_OUT] = NOT(cpu->latch[M6502_LATCH_ASRL_IN]);
    }
    if (PHI2) {
        cpu->latch[M6502_LATCH_SHIFT_IN] = NOT ( cpu->ctrl[M6502_CTRL_nSHIFT] | MEMOP | nREADY );
        cpu->latch[M6502_LATCH_SHR_IN] = cpu->ctrl[M6502_CTRL_SH_R];
        cpu->latch[M6502_LATCH_ASRL_IN] = NAND(NOT(nREADY), cpu->ctrl[M6502_CTRL_SH_R]);
    }
    SRS = NOT (NAND(cpu->ctrl[M6502_CTRL_SH_R], PLA(76)) & NOT(PLA(75)) );

    // Y/SB X/SB
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_X_SB] = NOT ( PLA(8) | PLA(9) | PLA(10) | PLA(11) | PLA(13) | NAND(STOR, PLA(12)) | NAND(NOT(PLA(7)),PLA(6)) );
    cpu->bus[M6502_BUS_RANDOM][M6502_X_SB] = NOR(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_X_SB], PHI2) & NOT(PHI2) ;

    // SB/DB

    // interrupt handling. 0/ADL0, 0/ADL1, 0/ADL2.
    p = NOR ( cpu->latch[M6502_LATCH_INTR_RESET], cpu->latch[M6502_LATCH_INTR] );
    if (PHI1) cpu->latch[M6502_LATCH_INTR] = NOT(p) & NOT(cpu->ctrl[M6502_CTRL_BRKDONE]);
    RD = NOT(p);
    if (PHI2) {
        cpu->latch[M6502_LATCH_INTR_RESET] = cpu->ctrl[M6502_CTRL_RES];
        cpu->reg[M6502_REG_RANDOM_LATCH][M6502_0_ADL0] = NOT(PLA(22)) | nREADY;
        cpu->reg[M6502_REG_RANDOM_LATCH][M6502_0_ADL1] = cpu->ctrl[M6502_CTRL_VEC] | NOT(RD);
        cpu->reg[M6502_REG_RANDOM_LATCH][M6502_0_ADL2] = NOT ( cpu->ctrl[M6502_CTRL_VEC] | cpu->ctrl[M6502_CTRL_NMIG] | RD );
    }
    if (cpu->ctrl[M6502_CTRL_NMIG]) cpu->latch[M6502_LATCH_INTR_NMIG] = NOR ( cpu->ctrl[M6502_CTRL_I_OUT] & NOT(cpu->ctrl[M6502_CTRL_BRKDONE]), cpu->ctrl[M6502_CTRL_IRQ] );
    cpu->bus[M6502_BUS_RANDOM][M6502_0_ADL0] = NOT(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_0_ADL0]);
    cpu->bus[M6502_BUS_RANDOM][M6502_0_ADL1] = NOT(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_0_ADL1]);
    cpu->bus[M6502_BUS_RANDOM][M6502_0_ADL2] = cpu->reg[M6502_REG_RANDOM_LATCH][M6502_0_ADL2];

    // flags.
    cpu->ctrl[M6502_CTRL_I_C] = cpu->latch[M6502_LATCH_FCTRL_ICOUT];
    if (PHI1) {
        cpu->latch[M6502_LATCH_FCTRL_ICOUT] = NAND(cpu->latch[M6502_LATCH_FCTRL_ICIN], NOT(cpu->latch[M6502_LATCH_FCTRL_BR]));
        if (cpu->ctrl[M6502_CTRL_N_IN]) cpu->latch[M6502_LATCH_FCTRL_ICOUT] &= NOT(cpu->latch[M6502_LATCH_FCTRL_BR]);
    }
    if (PHI2) {
        cpu->latch[M6502_LATCH_FCTRL_IC] = PLA(108);
        cpu->latch[M6502_LATCH_FCTRL_CC] = ARIT;
        cpu->latch[M6502_LATCH_FCTRL_ZC] = NOR(PLA(109), LOG1) & cpu->latch[M6502_LATCH_FCTRL_CC];
        cpu->latch[M6502_LATCH_FCTRL_NC] = PLA(109);
        cpu->latch[M6502_LATCH_FCTRL_0P] = NOR (PLA(114), PLA(115));
        cpu->latch[M6502_LATCH_FCTRL_VC2] = NOT(PLA(113));
        cpu->latch[M6502_LATCH_FCTRL_BR] = BR2;
        cpu->latch[M6502_LATCH_POUT] = NOR (PLA(98), PLA(99));
    }
    cpu->ctrl[M6502_CTRL_PDB] = NOT(cpu->latch[M6502_LATCH_POUT]);

    // branch taken?
    bb6 = PLA(121); bb6 = PLA(126);     // grab some important bits, to distinguish branch type
    res = NOT (     // and do some magiks
        NOT (cpu->ctrl[M6502_CTRL_C_OUT] | bb7 | NOT(bb6) )      |
        NOT (cpu->ctrl[M6502_CTRL_V_OUT] | bb6 | NOT(bb7) )      |
        NOT (cpu->ctrl[M6502_CTRL_N_OUT] | NOT(bb7) | NOT(bb6) ) |
        NOT (cpu->ctrl[M6502_CTRL_Z_OUT] | bb6 | bb7 )  );
    cpu->ctrl[M6502_CTRL_BRTAKEN] = NAND(res, nIR(5)) & (res | nIR(5));

    // increment PC.
    sync = NOT(cpu->latch[M6502_LATCH_SYNC]);

    // PC setup
    if (PHI1) cpu->latch[M6502_LATCH_PCREADY] = nREADY;
    JB = NOR( PLA(94), PLA(95) );
    PCHDB = NOR( PLA(77), PLA(78) );
    if (PHI2) cpu->latch[M6502_LATCH_PCHDB] = PCHDB;
    if (PHI1) cpu->latch[M6502_LATCH_PCLDB] = NOR (cpu->latch[M6502_LATCH_PCHDB], nREADY);
    PCLDB = NOT (cpu->latch[M6502_LATCH_PCLDB]);
    PCDB = NAND(PCHDB, PCLDB);
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCH_DB] = PCHDB;
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCL_DB] = PCLDB;
    cpu->bus[M6502_BUS_RANDOM][M6502_PCH_DB] = NOT(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCH_DB]);
    cpu->bus[M6502_BUS_RANDOM][M6502_PCL_DB] = NOT(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCL_DB]);
    ADHPCH = NOT ( PLA(83) | PLA(84) | PLA(93) | sync | BR2 | cpu->ctrl[M6502_CTRL_T1] );
    PCHPCH = NOT (ADHPCH);
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_ADH_PCH] = ADHPCH;
    cpu->bus[M6502_BUS_RANDOM][M6502_ADH_PCH] = NOR ( cpu->reg[M6502_REG_RANDOM_LATCH][M6502_ADH_PCH], PHI2) & NOT(PHI2);
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCH_PCH] = PCHPCH;
    cpu->bus[M6502_BUS_RANDOM][M6502_PCH_PCH] = NOR ( cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCH_PCH], PHI2) & NOT(PHI2);
    PCLADL = NOT(PLA(83) | BR2 | PLA(56) | sync | NOR (NOT(JB) & NOT(cpu->latch[M6502_LATCH_PCREADY]), NOT(cpu->ctrl[M6502_CTRL_T1])));
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCL_ADL] = PCLADL;
    cpu->bus[M6502_BUS_RANDOM][M6502_PCL_ADL] = NOT(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCL_ADL]);
    ADLPCL = NOT (PLA(84) | NAND(NOT(nREADY), PLA(93)) | NOT(PCLADL) | cpu->ctrl[M6502_CTRL_T1] );
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_ADL_PCL] = ADLPCL;
    cpu->bus[M6502_BUS_RANDOM][M6502_ADL_PCL] = NOR(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_ADL_PCL], PHI2) & NOT(PHI2);
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCL_PCL] = NOT(ADLPCL);
    cpu->bus[M6502_BUS_RANDOM][M6502_PCL_PCL] = NOR(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCL_PCL], PHI2) & NOT(PHI2);
    if (PHI2) cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCH_ADH] = NOR ( NOT(PCLADL | PLA(73) | NOR(JB, NOT(cpu->ctrl[M6502_CTRL_T1]))), PLA(93));
    cpu->bus[M6502_BUS_RANDOM][M6502_PCH_ADH] = NOT(cpu->reg[M6502_REG_RANDOM_LATCH][M6502_PCH_ADH]);

    // ALU setup

    // R/W select

    // execution control
    if (PHI2) cpu->latch[M6502_LATCH_SYNCTOIR] = sync;
    cpu->ctrl[M6502_CTRL_FETCH] = NOR ( NOT(cpu->latch[M6502_LATCH_SYNCTOIR]), nREADY);
    cpu->ctrl[M6502_CTRL_CLEARIR] = NAND ( cpu->ctrl[M6502_CTRL_FETCH], cpu->ctrl[M6502_CTRL_B_OUT] );
    cpu->pad[M6502_PAD_SYNC] = sync;    // sync to output pad

    if (cpu->debug[M6502_DEBUG_OUT]) dump_random (cpu);
}

// instruction register
static void INSTR_REG (ContextM6502 *cpu)
{
    int b;
    if ( PHI1 && cpu->ctrl[M6502_CTRL_FETCH] ) {
        for (b=0; b<8; b++) cpu->reg[M6502_REG_IR][b] = cpu->reg[M6502_REG_PD][b] & NOT(cpu->ctrl[M6502_CTRL_CLEARIR]);
    }
}

// ------------------------------------------------------------------------
// BOTTOM PART

// Data latch -> Regs -> ALU -> Program counter -> Address bus

static void DATA_BUS (ContextM6502 *cpu)
{
    int b, bit;

    for (b=0; b<8; b++) {
        if (PHI2) DL(b) = NOT(DATA_RD(b));  // feed data latch
        if (cpu->bus[M6502_BUS_RANDOM][M6502_DL_ADL] && PHI1) ADL(b) = NOT(DL(b));
        if (cpu->bus[M6502_BUS_RANDOM][M6502_DL_ADH] && PHI1) ADH(b) = NOT(DL(b));
        if (cpu->bus[M6502_BUS_RANDOM][M6502_DL_DB] && PHI1) DB(b) = NOT(DL(b));
        if (PHI1) DOR(b) = NOT(DB(b));
        if ( NOT(cpu->ctrl[M6502_CTRL_RWLATCH]) ) {
            DATA_WR(b, NOT(DOR(b)));
            if (PHI2) DL(b) = NOT(DATA_RD(b));  // update data latch
        }
    }

    if (cpu->debug[M6502_DEBUG_OUT]) printf ( "DBUS:%02X ", cpu->pad[M6502_PAD_DATA]);
}

// Stack register is inverted logic, so its 0x1FF after reset.
static void REGS (ContextM6502 *cpu)
{
    int b;
    if (PHI2) {
        cpu->bus[M6502_BUS_RANDOM][M6502_Y_SB] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_SB_Y] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_X_SB] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_SB_X] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_SB_S] = 0;
    }
    for (b=0; b<8; b++) {
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_Y_SB] ) SB(b) = Y(b);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_Y] ) Y(b) = SB(b);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_X_SB] ) SB(b) = X(b);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_X] ) X(b) = SB(b);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_S] & PHI2 ) S(b) = NOT(SB(b));
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_S_SB] ) SB(b) = NOT(S(b));
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_S_ADL] ) ADL(b) = NOT(S(b));
    }

    if (cpu->debug[M6502_DEBUG_OUT]) printf ( "X:%02X Y:%02X S:%02X ", packreg(cpu->reg[M6502_REG_X],8), packreg(cpu->reg[M6502_REG_Y],8), ~packreg(cpu->reg[M6502_REG_S],8) & 0xff );
}

// ALU using optimized carry chain, which is inverted every next stage.
// This allow to eliminate some silicon and reduce propagation delay.
// Details: http://forum.6502.org/viewtopic.php?f=8&t=2208&start=30#p20371

// US Pat. 3991307
// INTEGRATED CIRCUIT MICROPROCESSOR WITH PARALLEL BINARY ADDER HAVING 
// ON-THE-FLY CORRECTION TO PROVIDE DECIMAL RESULTS.

static void ALU (ContextM6502 *cpu)
{
    int n, a, b, c, carry_in, carry_out;
    char NANDs[8], NORs[8], ENORs[8], EORs[8];
    int DHC = 0, DC = 0, DACR;    // decimal half-carry and carry

    char *op = NULL;
    if ( cpu->bus[M6502_BUS_RANDOM][M6502_ORS] ) op = "|";
    else if ( cpu->bus[M6502_BUS_RANDOM][M6502_ANDS] ) op = "&";
    else if ( cpu->bus[M6502_BUS_RANDOM][M6502_SRS] ) op = ">>";
    else if ( cpu->bus[M6502_BUS_RANDOM][M6502_EORS] ) op = "^";
    else if ( cpu->bus[M6502_BUS_RANDOM][M6502_SUMS] ) op = "+";

    // Disconnect internal buses from ALU in read mode.
    if ( PHI2 ) {
        cpu->bus[M6502_BUS_RANDOM][M6502_nDB_ADD] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_DB_ADD] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_ADL_ADD] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_SB_ADD] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_0_ADD] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_SB_AC] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_AC_SB] = 
        cpu->bus[M6502_BUS_RANDOM][M6502_AC_DB] = 0;
    }

    // A/B INPUT
    for (n=0; n<8; n++) {
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_nDB_ADD] ) BI(n) = NOT(DB(n));
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_DB_ADD] ) BI(n) = DB(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_ADL_ADD] ) BI(n) = ADL(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_ADD] ) AI(n) = SB(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_0_ADD] ) AI(n) = 0;
    }

    // LOGIC (based on NAND/NOR)
    for (n=0; n<8; n++) {
        NORs[n] = NOR(AI(n), BI(n));
        NANDs[n] = NAND(AI(n), BI(n));
        if ( n & 1) EORs[n] = NOR(NOT(NANDs[n]), NORs[n]);
        else ENORs[n] = NAND(NOT(NORs[n]), NANDs[n]);

        if ( PHI2 ) {
            if ( cpu->bus[M6502_BUS_RANDOM][M6502_ORS] ) ADD(n) = NORs[n];
            if ( cpu->bus[M6502_BUS_RANDOM][M6502_ANDS] ) ADD(n) = NANDs[n];
            if ( cpu->bus[M6502_BUS_RANDOM][M6502_SRS] && n ) ADD(n-1) = NANDs[n];
            if ( cpu->bus[M6502_BUS_RANDOM][M6502_EORS] ) {
                if ( n & 1 ) ADD(n) = NOT(EORs[n]);
                else ADD(n) = ENORs[n];
            }
        }
    }

    // Sum carry chain with decimal carry look-ahead
    carry_out = cpu->bus[M6502_BUS_RANDOM][M6502_I_ADDC];
    for (n=0; n<8; n++) {
        carry_in = carry_out;

        if ( n == 7 ) { // Overflow test
            if ( PHI2 ) cpu->latch[M6502_LATCH_AVR] = NAND(NORs[7], carry_out) & (NANDs[7] | carry_out);
            cpu->bus[M6502_BUS_RANDOM][M6502_AVR] = NOT(cpu->latch[M6502_LATCH_AVR]);
        }

        if ( n & 1)  {
            carry_out = NAND(NOT(NORs[n]), carry_in) & NANDs[n];
            if (n == 3) carry_out &= NOT(DHC);
            if ( cpu->bus[M6502_BUS_RANDOM][M6502_SUMS] && PHI2 ) {
                ADD(n) = NAND(EORs[n], NOT(carry_in)) & (EORs[n] | NOT(carry_in));
            }
        }
        else {
            carry_out = NAND(NANDs[n], carry_in) & NOT(NORs[n]);
            if ( cpu->bus[M6502_BUS_RANDOM][M6502_SUMS] && PHI2 ) {
                ADD(n) = NAND(ENORs[n], NOT(carry_in)) & (ENORs[n] | NOT(carry_in));
            }
        }

        if (n == 0) {   // decimal half-carry look-ahead
            a = NOR( NAND(NOT(NANDs[1]), carry_out), NORs[2] );
            b = NOR(EORs[3], NOT(NANDs[2]));
            c = NOR(EORs[1], NOT(NANDs[1])) & NOT(carry_out) & (NOT(NANDs[2]) | NORs[2]);
            DHC = a & (b | c) & NOT(cpu->bus[M6502_BUS_RANDOM][M6502_DAA]);
        }
        if (n == 4) {   // decimal carry look-ahead
            a = NOR( NAND(NOT(NANDs[5]), carry_out), EORs[6]);
            b = NOR(NOT(NANDs[6]), EORs[7]);
            c = NOR(NOT(NANDs[5]), EORs[5]) & NOR(carry_out, NOT(EORs[6]));
            DC = a & (b | c) & NOT(cpu->bus[M6502_BUS_RANDOM][M6502_DAA]);
        }
    }

    // Carry output
    if ( PHI2 ) {
        cpu->latch[M6502_LATCH_DAA] = NOT(cpu->bus[M6502_BUS_RANDOM][M6502_DAA]);
        cpu->latch[M6502_LATCH_BCARRY] = NOT(carry_out);
        cpu->latch[M6502_LATCH_DCARRY] = DC;
        cpu->bus[M6502_BUS_RANDOM][M6502_ACR] = cpu->latch[M6502_LATCH_BCARRY] | cpu->latch[M6502_LATCH_DCARRY];
    }
    DACR = NOR ( NOR(cpu->latch[M6502_LATCH_BCARRY], cpu->latch[M6502_LATCH_DCARRY]), NOT(cpu->latch[M6502_LATCH_DAA]) );

    // Accumulator and adder hold outputs.
    for (n=0; n<8; n++) {
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_ADD_ADL] ) ADL(n) = NOT(ADD(n));
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_ADD_SB06] && n != 7 ) SB(n) = NOT(ADD(n));
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_ADD_SB7] && n == 7 ) SB(n) = NOT(ADD(n));
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_DB] ) DB(n) = SB(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_AC] ) AC(n) = SB(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_AC_SB] ) SB(n) = AC(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_AC_DB] ) DB(n) = AC(n);
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_SB_ADH] ) ADH(n) = SB(n);
    }

    if (op && cpu->debug[M6502_DEBUG_OUT]) printf ( "AI:%02X %s BI:%02X = ADD:%02X AC:%02X ", packreg(cpu->reg[M6502_REG_AI],8), op, packreg(cpu->reg[M6502_REG_BI],8), ~packreg(cpu->reg[M6502_REG_ADD],8) & 0xff, packreg(cpu->reg[M6502_REG_AC],8) );
}

static void PROGRAM_COUNTER (ContextM6502 *cpu)
{

    if (cpu->debug[M6502_DEBUG_OUT]) printf ( "PC:%02X%02X ", packreg(cpu->reg[M6502_REG_PCH],8), packreg(cpu->reg[M6502_REG_PCL],8) );
}

// ADH/ADL are high during PHI2 (precharged)
// ABH/ABL register latches are refreshed during PHI2.
// ABH/ABL use inverted logic, so address bus is 0xFFFF after reset + 3 low bits are cleared according to interrupt.
static void ADDRESS_BUS (ContextM6502 *cpu)
{
    int b;

    if (cpu->bus[M6502_BUS_RANDOM][M6502_0_ADL0]) ADL(0) = 0;
    if (cpu->bus[M6502_BUS_RANDOM][M6502_0_ADL1]) ADL(1) = 0;
    if (cpu->bus[M6502_BUS_RANDOM][M6502_0_ADL2]) ADL(2) = 0;

    for (b=0; b<8; b++) {
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_0_ADH0] && b == 0 ) ADH(b) = 0;
        if ( cpu->bus[M6502_BUS_RANDOM][M6502_0_ADH17] && b != 0 ) ADH(b) = 0;
        if (cpu->bus[M6502_BUS_RANDOM][M6502_ADL_ABL] && PHI1) ABL(b) = NOT(ADL(b));
        if (cpu->bus[M6502_BUS_RANDOM][M6502_ADH_ABH] && PHI1) ABH(b) = NOT(ADH(b));
        ADDR_WR (b, NOT(ABL(b)));
        ADDR_WR (8+b, NOT(ABH(b)));
    }

    if (cpu->debug[M6502_DEBUG_OUT]) printf ( "ABUS:%04X ", cpu->pad[M6502_PAD_ADDR]);
}

// ------------------------------------------------------------------------

void M6502Step (ContextM6502 *cpu)
{
    int b;

    // Top part.
    CLOCK (cpu);
    PADS (cpu);
    READY_CONTROL (cpu);
    CYCLE_COUNTER (cpu);
    PREDECODE (cpu);
    PLA_DECODE (cpu);
    INTERRUPTS (cpu);
    RANDOM_LOGIC (cpu);
    INSTR_REG (cpu);

    // Precharge
    for (b=0; b<8; b++) SB(b) = DB(b) = ADH(b) = ADL(b) = 1;
    // Bottom part.
    DATA_BUS (cpu);
    REGS (cpu);
    ALU (cpu);
    PROGRAM_COUNTER (cpu);
    ADDRESS_BUS (cpu);
    if ( cpu->debug[M6502_DEBUG_OUT] ) {
        printf ( "SB:%02X DB:%02X AD:%02X%02X ", packreg(cpu->bus[M6502_BUS_SB],8), packreg(cpu->bus[M6502_BUS_DB],8), packreg(cpu->bus[M6502_BUS_ADH],8), packreg(cpu->bus[M6502_BUS_ADL],8) );
        printf ("\n\n");
    }

    cpu->debug[M6502_DEBUG_CLKCOUNT]++;
}

void M6502Debug (ContextM6502 *cpu, char *cmd)
{
         if ( !stricmp (cmd, "CLK") ) CLOCK (cpu);
    else if ( !stricmp (cmd, "PADS") ) PADS (cpu);
    else if ( !stricmp (cmd, "RDY") ) READY_CONTROL (cpu);
    else if ( !stricmp (cmd, "TR") ) CYCLE_COUNTER (cpu);
    else if ( !stricmp (cmd, "PD") ) PREDECODE (cpu);
    else if ( !stricmp (cmd, "PLA") ) PLA_DECODE (cpu);
    else if ( !stricmp (cmd, "INTR") ) INTERRUPTS (cpu);
    else if ( !stricmp (cmd, "LOGIC") ) RANDOM_LOGIC (cpu);
    else if ( !stricmp (cmd, "IR") ) INSTR_REG (cpu);

    else if ( !stricmp (cmd, "DBUS") ) DATA_BUS (cpu);
    else if ( !stricmp (cmd, "REGS") ) REGS (cpu);
    else if ( !stricmp (cmd, "ALU") ) ALU (cpu);
    else if ( !stricmp (cmd, "ABUS") ) PROGRAM_COUNTER (cpu);
    else if ( !stricmp (cmd, "PADS") ) ADDRESS_BUS (cpu);
}

char * PLAName (int n) { return PLA_ROM[n].name; }
