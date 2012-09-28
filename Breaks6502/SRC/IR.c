// instruction register logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void InstructionRegister (Context6502 * cpu)
{
    int b;

    if ( cpu->PHI1 && cpu->fetch ) {
        for (b=0; b<8; b++) cpu->IR[b] = cpu->PD[b] & ~cpu->clearIR;
    }    
}
