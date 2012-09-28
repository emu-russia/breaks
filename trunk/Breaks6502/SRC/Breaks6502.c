#include "Breaks6502.h"
#include "Breaks6502Private.h"

__declspec( dllexport ) void Step6502 ( Context6502 * cpu )
{
    // Clock distribution.

    cpu->PHI1 = BIT(~cpu->PHI0);
    cpu->PHI2 = BIT(cpu->PHI0);

    // Dispatch top part logic
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
}

// Execute specific 6502 subsystem for debug purposes.
__declspec( dllexport ) void Debug6502 ( Context6502 * cpu, char * cmd )
{
    if ( !stricmp (cmd, "MISC") ) {
    }
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
