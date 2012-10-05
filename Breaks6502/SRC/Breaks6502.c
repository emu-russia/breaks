#include "Breaks6502.h"
#include "Breaks6502Private.h"

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

// Basic logic
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

__declspec( dllexport ) void Step6502 ( Context6502 * cpu )
{
    // Dispatch top part logic
    MiscLogic (cpu);
    Predecode (cpu);
    RandomLogicEarly (cpu);
    InstructionRegister (cpu);
    TcountRegister (cpu);
    DecodePLA (cpu);
    RandomLogic (cpu);

    // Bottom part
    DataLatch (cpu);
    ALU (cpu, !cpu->NoDecimalCorrection);
    Regs (cpu);
    ProgramCounter (cpu);
    AddressBus (cpu);

    if (cpu->DEBUG) printf ("\n");  // next step linebreak
}

// Execute specific 6502 subsystem for debug purposes.
__declspec( dllexport ) void Debug6502 ( Context6502 * cpu, char * cmd )
{
         if ( !stricmp (cmd, "MISC") ) MiscLogic (cpu);
    else if ( !stricmp (cmd, "TSTEP") ) TcountRegister (cpu);
    else if ( !stricmp (cmd, "IR") ) InstructionRegister (cpu);
    else if ( !stricmp (cmd, "PLA") ) DecodePLA (cpu);
    else if ( !stricmp (cmd, "PREDECODE") ) Predecode (cpu);
    else if ( !stricmp (cmd, "RANDOM1") ) RandomLogicEarly (cpu);
    else if ( !stricmp (cmd, "RANDOM2") ) RandomLogic (cpu);
    else if ( !stricmp (cmd, "ALU") ) ALU (cpu, !cpu->NoDecimalCorrection);
    else if ( !stricmp (cmd, "DATA") ) DataLatch (cpu);
    else if ( !stricmp (cmd, "REGS") ) Regs (cpu);
    else if ( !stricmp (cmd, "PC") ) ProgramCounter (cpu);
    else if ( !stricmp (cmd, "ADDR") ) AddressBus (cpu);
}
