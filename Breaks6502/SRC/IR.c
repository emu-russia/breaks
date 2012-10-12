// instruction register logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void InstructionRegister (Context6502 * cpu)
{
    int b;

    if ( cpu->PHI1 && cpu->fetch ) {
        for (b=0; b<8; b++) cpu->IR[b] = cpu->PD[b] & NOT(cpu->clearIR);
        if (cpu->DEBUG) printf ( "IR=%02X\n", packreg(cpu->IR, 8) );
    }
    else {
        if (cpu->DEBUG) printf ( "IR unchanged: PHI1=%i / fetch=%i\n", cpu->PHI1, cpu->fetch );
    }
}
