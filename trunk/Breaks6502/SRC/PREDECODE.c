// predecode logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void Predecode (Context6502 * cpu)
{
    int b;
    if ( cpu->PHI2 ) {
        for (b=0; b<8; b++) cpu->PD[b] = NOT(cpu->DATA[b]);
    }
}
