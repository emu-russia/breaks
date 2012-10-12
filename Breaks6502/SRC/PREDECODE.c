// predecode logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

// Two-cycles instructions are all implied (except push/pull) + ALU ops with #immed operand.

void Predecode (Context6502 * cpu)
{
    int b, p[4] = { 1, 1, 1, 1 };
    if ( cpu->PHI2 ) {
        for (b=0; b<8; b++) cpu->PD[b] = NOT(cpu->DATA[b]);
    }

    // Determine whenever instruction takes 2 cycle / implied.

    if ( cpu->PD[2] || NOT(cpu->PD[3]) || cpu->PD[4] || NOT(cpu->PD[0]) ) p[0] = 0;
    if ( cpu->PD[2] || NOT(cpu->PD[3]) || cpu->PD[0] ) p[1] = 0;
    if ( cpu->PD[4] || cpu->PD[7] || cpu->PD[1] ) p[2] = 0;
    if ( cpu->PD[2] || cpu->PD[3] || cpu->PD[4] || NOT(cpu->PD[7]) || cpu->PD[0] ) p[3] = 0;

    cpu->Not_twocycle = 1;
    if ( p[0] || p[3] || (NOT(p[2]) & p[1]) ) cpu->Not_twocycle = 0;

    cpu->Not_implied = NOT(p[1]);    
}
