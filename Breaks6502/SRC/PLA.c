// PLA instruction decoder
#include "Breaks6502.h"
#include "Breaks6502Private.h"

// T1X T0 /5 5 /6 6 /2 2 /3 3 /4 4 /7 7 /0 0|1 /1 T2 T3 T4 T5

static char * PLA_ROM[129] = {     // 129 active lines.

    "000101100000100100000",   // 100XX100 TX     STY
    "000000010110001000100",   // XXX100X1 T3     OP ind, Y
    "000000011010001001000",   // XXX110X1 T2     OP abs, Y
    "010100011001100100000",   // 1X001000 T0     DEY INY
    "010101011010100100000",   // 10011000 T0     TYA
    "010110000001100100000",   // 1100XX00 T0     CPY INY

    "000000100010000001000",   // XXX1X1XX T2     OP zpg, X/Y & OP abs, X/Y
    "000001000000100010000",   // 10XXXX1X TX     LDX STX A<->X S<->X
    "000000010101001001000",   // XXX000X1 T2     OP ind, X
    "010101011001100010000",   // 1000101X T0     TXA
    "010110011001100010000",   // 1100101X T0     DEX
    "011010000001100100000",   // 1110XX00 T0     CPX INX
    "000101000000100010000",   // 100XXX1X TX     STX TXA TXS
    "010101011010100010000",   // 1001101X T0     TXS
    "011001000000100010000",   // 101XXX1X T0     LDX TAX TSX
    "100110011001100010000",   // 1100101X T1     DEX
    "101010011001100100000",   // 11101000 T1     INX
    "011001011010100010000",   // 1011101X T0     TSX
    "100100011001100100000",   // 1X001000 T1     DEY INY
    "011001100000100100000",   // 101XX100 T0     LDY
    "011001000001100100000",   // 1010XX00 T0     LDY TAY

    "011001010101010100000",   // 00100000 T0     JSR
    "000101010101010100001",   // 00000000 T5     BRK
    "010100011001010100000",   // 0X001000 T0     Push
    "001010010101010100010",   // 01100000 T4     RTS
    "001000011001010100100",   // 0X101000 T3     Pull
    "000110010101010100001",   // 01000000 T5     RTI
    "001010000000010010000",   // 011XXX1X TX     ROR
    "000000000000000001000",   // XXXXXXXX T2     T2 ANY
    "010110000000011000000",   // 010XXXX1 T0     EOR
    "000010101001010100000",   // 01X01100 TX     JMP (excluder for C11)
    "000000101001000001000",   // XXX011XX T2     ALU absolute
    "010101000000011000000",   // 000XXXX1 T0     ORA
    "000000000100000001000",   // XXXX0XXX T2     LEFT ALL
    "010000000000000000000",   // XXXXXXXX T0     T0 ANY
    "000000010001010101000",   // 0XX0X000 T2     BRK JSR RTI RTS Push/pull
    "000000000001010100100",   // 0XX0XX00 T3     BRK JSR RTI RTS Push/pull + BIT JMP

    "000001010101010100010",   // 00X00000 T4     BRK JSR
    "000110010101010100010",   // 01000000 T4     RTI
    "000000010101001000100",   // XXX000X1 T3     OP X, ind
    "000000010110001000010",   // XXX100X1 T4     OP ind, Y
    "000000010110001001000",   // XXX100X1 T2     OP ind, Y
    "000000001010000000100",   // XXX11XXX T3     RIGHT ODD
    "001000011001010100000",   // 0X101000 TX     Pull
    "001010000000100010000",   // 111XXX1X TX     INC NOP
    "000000010101001000010",   // XXX000X1 T4     OP X, ind
    "000000010110001000100",   // XXX100X1 T3     OP ind, Y
    "000010010101010100000",   // 01X00000 TX     RTI RTS
    "001001010101010101000",   // 00100000 T2     JSR
    "010010000001100100000",   // 11X0XX00 T0     CPY CPX INY INX
    "010110000000101000000",   // 110XXXX1 T0     CMP
    "011010000000101000000",   // 111XXXX1 T0     SBC
    "011010000000001000000",   // X11XXXX1 T0     ADC SBC
    "001001000000010010000",   // 001XXX1X TX     ROL

    "000010101001010100100",   // 01X01100 T3     JMP
    "000001000000010010000",   // 00XXXX1X TX     ASL ROL
    "001001010101010100001",   // 00100000 T5     JSR
    "000000010001010101000",   // 0XX0X000 T2     BRK JSR RTI RTS Push/pull
    "010101011010100100000",   // 10011000 T0     TYA
    "100000000000011000000",   // 0XXXXXX1 T1     UPPER ODD
    "101010000000001000000",   // X11XXXX1 T1     ADC SBC
    "100000011001010010000",   // 0XX0101X T1     ASL ROL LSR ROR
    "010101011001100010000",   // 1000101X T0     TXA
    "011010011001010100000",   // 01101000 T0     PLA
    "011001000000101000000",   // 101XXXX1 T0     LDA
    "010000000000001000000",   // XXXXXXX1 T0     ALL ODD
    "011001011001100100000",   // 10101000 T0     TAY
    "010000011001010010000",   // 0XX0101X T0     ASL ROL LSR ROR
    "011001011001100010000",   // 1010101X T0     TAX
    "011001100001010100000",   // 0010X100 T0     BIT
    "011001000000011000000",   // 001XXXX1 T0     AND
    "000000001010000000010",   // XXX11XXX T4     RIGHT ODD
    "000000010110001000001",   // XXX100X1 T5     OP ind, Y

    "010000010110000100000",   // XXX10000 T0 <-  Branch + BranchReady line
    "000110011001010101000",   // 01001000 T2     PHA
    "010010011001010010000",   // 01X0101X T0     LSR ROR
    "000010000000010010000",   // 01XXXX1X TX     LSR ROR
    "000101010101010101000",   // 00000000 T2     BRK
    "001001010101010100100",   // 00100000 T3     JSR
    "000101000000101000000",   // 100XXXX1 TX     STA
    "000000010110000101000",   // XXX10000 T2     Branch
    "000000100100000001000",   // XXXX01XX T2     zero page
    "000000010100001001000",   // XXXX00X1 T2     ALU indirect
    "000000001000000001000",   // XXXX1XXX T2     RIGHT ALL -G07
    "001010010101010100001",   // 01100000 T5     RTS
    "000000000000000000010",   // XXXXXXXX T4     T4 ANY
    "000000000000000000100",   // XXXXXXXX T3     T3 ANY
    "010100010101010100000",   // 0X000000 T0     BRK RTI
    "010010101001010100000",   // 01X01100 T0     JMP
    "000000010101001000001",   // XXX000X1 T5     OP X, ind
    "000000001000000000100",   // XXXX1XXX T3     RIGHT ALL -G07

    "000000010110001000010",   // XXX100X1 T4     OP ind, Y
    "000000001010000000100",   // XXX11XXX T3     RIGHT ODD
    "000000010110000100100",   // XXX10000 T3     Branch
    "000100010101010100000",   // 0X000000 TX     BRK RTI
    "001001010101010100000",   // 00100000 TX     JSR
    "000010101001010100000",   // 01X01100 TX     JMP
//    "000000011001010100000",   // 0XX01000 TX <-  Push/pull, F11 & F18 excluder
    "000101000000100000000",   // 100XXXXX TX     80-9F
    "000101010101010100010",   // 00000000 T4     BRK
    "000101011001010101000",   // 00001000 T2     PHP
    "000100011001010101000",   // 0X001000 T2     Push
    "000010101001010100010",   // 01X01100 T4     JMP
    "000010010101010100001",   // 01X00000 T5     RTI RTS
    "001001010101010100001",   // 00100000 T5     JSR

    "000110101001010101000",   // 01001100 T2     JMP
    "001000011001010100100",   // 0X101000 T3     Pull
    "000010000000000010000",   // X1XXXX1X TX     LSR ROR DEC INC DEX NOP (4x4 bottom right)
    "000001000000010010000",   // 00XXXX1X TX     ASL ROL
    "010010011010010100000",   // 01X11000 T0     CLI SEI
    "101001100001010100000",   // 0010X100 T1     BIT
    "010001011010010100000",   // 00X11000 T0     CLC SEC
    "000000100110000000100",   // XXX101XX T3     Memory zero page X/Y
    "101010000000001000000",   // X11XXXX1 T1     ADC SBC
    "011001100001010100000",   // 0010X100 T0     BIT
    "011001011001010100000",   // 00101000 T0     PLP
    "000110010101010100010",   // 01000000 T4     RTI
    "100110000000101000000",   // 110XXXX1 T1     CMP
    "100010101001100100000",   // 11X01100 T1     CPY CPX abs
    "100001011001010010000",   // 00X0101X T1     ASL ROL
    "100010000101100100000",   // 11X00X00 T1     CPY CPX zpg/immed

//    "000000011001010100000",   // 0XX01000 TX     Not actually line. Controls last line to exlude push/pull opcodes --->
    "010010011010100100000",   // 11X11000 T0     CLD SED
    "000001000000000000000",   // X0XXXXXX TX     Branch bit 6
    "000000101001000000100",   // XXX011XX T3     Memory absolute
    "000000100101000001000",   // XXX001XX T2     Memory zero page
    "000000010100001000001",   // XXXX00X1 T5     Memory indirect
    "000000001010000000010",   // XXX11XXX T4     Memory absolute X/Y
    "000000000000010000000",   // 0XXXXXXX TX     Branch bit 7
    "001001011010100100000",   // 10111000 TX     CLV
    "000000011000000......",   // XXXX10X0 TX     All implied, except Push/pull

};

void DecodePLA (Context6502 * cpu)
{
    int b, n, out;
    char  IR[8], NOTIR[8], T[6];
    int BranchNotReady, IR01, PushPull;
    char * line;

    T[2] = BIT(cpu->Tcount);
    T[3] = BIT(cpu->Tcount >> 1);
    T[4] = BIT(cpu->Tcount >> 2);
    T[5] = BIT(cpu->Tcount >> 3);

    // BranchNotReady for line 73
    if (cpu->PHI2) cpu->BRLatch[0] = BIT(~cpu->RDY);
    if (cpu->PHI1) cpu->BRLatch[1] = BIT(~cpu->BRLatch[0]);
    BranchNotReady = BIT(~cpu->BRLatch[1]);

    for (b=0; b<8; b++) {
        IR[b] = BIT(~cpu->IR[b]);
        NOTIR[b] = BIT(cpu->IR[b]);
    }
    IR01 = IR[0] | IR[1];

    PushPull = ! ( IR[2] || NOTIR[3] || IR[4] || IR[7] || IR01 );

    for (n=0; n<128; n++) {
        out = 1;
        line = PLA_ROM[n];

        if ( T[1] && line[0] == '1' ) out = 0;
        if ( T[0] && line[1] == '1' ) out = 0;

        if ( NOTIR[5] && line[2] == '1' ) out = 0;
        if ( IR[5] && line[3] == '1' ) out = 0;
        if ( NOTIR[6] && line[4] == '1' ) out = 0;
        if ( IR[6] && line[5] == '1' ) out = 0;
        if ( NOTIR[2] && line[6] == '1' ) out = 0;
        if ( IR[2] && line[7] == '1' ) out = 0;
        if ( NOTIR[3] && line[8] == '1' ) out = 0;
        if ( IR[3] && line[9] == '1' ) out = 0;
        if ( NOTIR[4] && line[10] == '1' ) out = 0;
        if ( IR[4] && line[11] == '1' ) out = 0;
        if ( NOTIR[7] && line[12] == '1' ) out = 0;
        if ( IR[7] && line[13] == '1' ) out = 0;

        if ( NOTIR[0] && line[14] == '1' ) out = 0;
        if ( IR01 && line[15] == '1' ) out = 0;
        if ( NOTIR[1] && line[16] == '1' ) out = 0;

        if ( T[2] && line[17] == '1' ) out = 0;
        if ( T[3] && line[18] == '1' ) out = 0;
        if ( T[4] && line[19] == '1' ) out = 0;
        if ( T[5] && line[20] == '1' ) out = 0;

        // Line 73 has additional cutout by BranchNotReady
        if ( n == 73 && BranchNotReady ) out = 0;

        // Lines 83 and 90 are special with PushPull excluder
        if ( (n == 83 || n == 90) && PushPull ) out = 0;

        cpu->PLAOUT[n] = out;
    }

    // Last line is special (all implied, except push/pull)
    cpu->PLAOUT[n] = ! ( IR[2] || NOTIR[3] || IR[0] || PushPull );
}