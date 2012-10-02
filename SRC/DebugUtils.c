// Debug utils.
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <windows.h>

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

// Debug Console.
//

int DebugConsoleOpened = 0;

void OpenDebugConsole (void)
{
    int hConHandle;
    long lStdHandle;
    FILE *fp;

    if ( DebugConsoleOpened ) return;

    AllocConsole ();

    // redirect unbuffered STDOUT to the console
    lStdHandle = (long)GetStdHandle(STD_OUTPUT_HANDLE);
    hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);
    fp = (FILE *)_fdopen( hConHandle, "w" );
    *stdout = *fp;
    setvbuf( stdout, NULL, _IONBF, 0 );

    SetConsoleTitle("Breaks Debug Console");

    DebugConsoleOpened = 1;
}

void CloseDebugConsole (void)
{
    if (!DebugConsoleOpened) return;

    FreeConsole ();

    DebugConsoleOpened = 0;
}

void DPrintf (char *fmt, ...)
{
    if ( DebugConsoleOpened )
    {
        va_list arg;
        char buf[0x1000];

        va_start(arg, fmt);
        vsprintf(buf, fmt, arg);
        va_end(arg);

        printf ("%s", buf);
    }
}

// PLA names.

char * PLAName (int line)
{
    static char def[32];

    switch (line) {
        case 0: return "0";

        default:
            sprintf (def, "%i", line);
            return def;
    }
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
