#include "Breaks6502.h"
#include "Breaks6502Private.h"

void Step6502 ( Context6502 * cpu )
{
    // Clock distribution.

    cpu->PHI1 = BIT(~cpu->PHI0);
    cpu->PHI2 = BIT(cpu->PHI0);

    // Dispatch top part logic
    Predecode (cpu);
    RandomLogicEarly (cpu);
    //InstructionRegister (cpu);
    //TcountRegister (cpu);
    DecodePLA (cpu);
    RandomLogic (cpu);

    // Bottom part
    DataLatch (cpu);
    //ALU (cpu, 1);
    Regs (cpu);
    ProgramCounter (cpu);
    //AddressBus (cpu);
}