#include <stdio.h>
#include "Breaks6502.h"
#include "Breaks6502Private.h"

#include "ROM2364.h"
#include "ASM.h"

Context6502 cpu;

// Timing register
// Imitate behaviour of long CPU instruction.
void TimeRegTest (void)
{
    int r = 20, TR;
    int sync = 2;

    while (r--)
    {
        cpu.PHI1 = BIT(~cpu.PHI0);
        cpu.PHI2 = BIT(cpu.PHI0);
        cpu.sync = sync > 0;
        cpu.ready = 1;
        cpu.TRES = 0;
        TR = TcountRegister (&cpu);
        printf ( "%02X ", TR );
        cpu.PHI0 ^= 1;
        sync--;
    }

    // Output should be like: 0F 0F 0E 0E 0D 0D 0B 0B 07 07 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F
}

// http://visual6502.org/wiki/index.php?title=6502DecimalMode
void ALUTest (void)
{
}

void GeneralExecutionTest (i)
{
    // Execute given amount of clock iterations
    while (i--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }
}

// Execute some clocks to reset 6502
void Reset (void)
{
    int r = 100;
    cpu.RES = 0;
    while (r--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }
}

void *FileLoad(char *filename, long *size, char *mode)
{
    FILE*   f;
    char*   buffer;
    long     filesize;

    if(size) *size = 0;

    f = fopen(filename, mode);
    if(f == NULL) return NULL;

    fseek(f, 0, SEEK_END);
    filesize = ftell(f);
    fseek(f, 0, SEEK_SET);

    buffer = (char*)malloc(filesize + 1);
    if(buffer == NULL)
    {
        fclose(f);
        return NULL;
    }
    memset(buffer, 0, filesize + 1);

    fread(buffer, 1, filesize, f);
    fclose(f);
    if(size) *size = filesize;    
    return buffer;
}

int FileSave (char *filename, void *data, long size, char *mode)
{
    FILE *f = fopen(filename, mode);
    if(f == NULL) return 0;

    fwrite(data, size, 1, f);
    fclose(f);
    return 1;
}

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

char * QuickDisa (unsigned char instr)
{
    return inames[instr];
}

static void TracePLA (void)
{
    Context6502 cpu;
    int op, i;
    char text[100000], *ptr = text;

    ptr += sprintf ( ptr, "<html>");
    ptr += sprintf ( ptr, "<style>\nhtml table {\n    font-family:Calibri; \n    font-size: 16px;\n    border-collapse: collapse; }\n");
    ptr += sprintf ( ptr, "html td {\n    border: 1px dotted; \n} \n</style> <table>");
    ptr += sprintf ( ptr, "<tr><td>op</td><td>instr</td><td>T0</td><td>T1X</td><td>T2</td><td>T3</td><td>T4</td><td>T5</td></tr>");
    for (op=0; op<=0xff; op++) {
        ptr += sprintf ( ptr, "<tr>");
        unpackreg (cpu.IR, (~op) & 0xff, 8);

        ptr += sprintf ( ptr, "<td>%02X</td>", op);
        ptr += sprintf ( ptr, "<td><nobr>%s</nobr></td>", QuickDisa(op) );

        cpu.T0 = 0; cpu.T1X = 1; cpu.Tcount = 0xF;
        DecodePLA (&cpu);
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.PLAOUT[i]) ptr += sprintf ( ptr, "%i ", i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.T0 = 1; cpu.T1X = 0; cpu.Tcount = 0xF;
        DecodePLA (&cpu);
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.PLAOUT[i]) ptr += sprintf ( ptr, "%i ", i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.T0 = 1; cpu.T1X = 1; cpu.Tcount = 0xE;
        DecodePLA (&cpu);
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.PLAOUT[i]) ptr += sprintf ( ptr, "%i ", i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.T0 = 1; cpu.T1X = 1; cpu.Tcount = 0xD;
        DecodePLA (&cpu);
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.PLAOUT[i]) ptr += sprintf ( ptr, "%i ", i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.T0 = 1; cpu.T1X = 1; cpu.Tcount = 0xB;
        DecodePLA (&cpu);
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.PLAOUT[i]) ptr += sprintf ( ptr, "%i ", i);
        }
        ptr += sprintf ( ptr, "</td>");

        cpu.T0 = 1; cpu.T1X = 1; cpu.Tcount = 0x7;
        DecodePLA (&cpu);
        ptr += sprintf ( ptr, "<td>");
        for (i=0; i<129; i++) {
            if (cpu.PLAOUT[i]) ptr += sprintf ( ptr, "%i ", i);
        }
        ptr += sprintf ( ptr, "</td>");

        ptr += sprintf ( ptr, "</tr>");
    }
    ptr += sprintf ( ptr, "</table></html>");

    FileSave ("PLA.htm", text, strlen(text), "wt");
}

void AsmTest (void)
{
    unsigned char prg[16*1024], *text;
    memset (prg, 0, sizeof(prg));
    text = FileLoad ("Test.asm", NULL, "rt" );
    assemble ( text, prg );
    FileSave ("prg.bin", prg, sizeof(prg), "wb");
}

void IntLatch (void)
{
    int INPUT_PAD;
    int OUTPUT_LINE;
    int DYNA_LATCH, DYNA_LATCH0, STAT_LATCH;
    int PHI2;
    int i, b;

    printf ( "L I P |L* O\n");
    for (i=0; i<8; i++) {

        PHI2 = BIT(i >> 0);
        INPUT_PAD = BIT(i >> 1);
        DYNA_LATCH = BIT(i >> 2);

/*
        DYNA_LATCH0 = DYNA_LATCH;
        b = NOR ( NOT(INPUT_PAD) & PHI2, DYNA_LATCH);
        DYNA_LATCH = NOR ( INPUT_PAD & PHI2, b );
        OUTPUT_LINE = NOT(DYNA_LATCH);
*/

        DYNA_LATCH0 = DYNA_LATCH;
        b = NOR ( INPUT_PAD & PHI2, DYNA_LATCH);
        DYNA_LATCH = NOR ( NOT(INPUT_PAD) & PHI2, b );
        if (PHI2 == 0) STAT_LATCH = DYNA_LATCH;
        OUTPUT_LINE = NOT(STAT_LATCH);

        printf ("%i %i %i | %i %i \n", DYNA_LATCH0, INPUT_PAD, PHI2, DYNA_LATCH, OUTPUT_LINE );
    }
}

static void PCTest (void)
{
    unpackreg ( cpu.PCHS, 0x1f, 8);
    unpackreg ( cpu.PCLS, 0xff, 8);

    cpu.DRIVEREG[DRIVE_IPC] = 0;
    cpu.DRIVEREG[DRIVE_PCL_PCL] = cpu.DRIVEREG[DRIVE_PCH_PCH] = 1;
    cpu.PHI2 = 1;
    ProgramCounter (&cpu);

    printf ( "PCLS = %02X, /PCLS = %02X\n", packreg(cpu.PCLS, 8), ~packreg(cpu.PCLS, 8) & 0xff);
    printf ( "PCHS = %02X, /PCHS = %02X\n", packreg(cpu.PCHS, 8), ~packreg(cpu.PCHS, 8) & 0xff);
}

main ()
{
}
