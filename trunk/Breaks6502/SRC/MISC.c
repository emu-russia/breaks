// Top-part input logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

/*
    Short notes:

    XXXDynaLatch is bistable trigger, clocked out by PHI2.

    XXXStatLatch is present only for /IRQ and RES pads, because these pads
    are "level-sensitive", instead of /NMI which is "edge-sensitive",
    which means that the NMI is triggered by the falling edge of 
    the signal rather than its level.

    FromXXX is output level of whole interrupt pad logic.
*/

void MiscLogic (Context6502 * cpu)
{
    int b;

    // Clock distribution.
    cpu->PHI1 = NOT(cpu->PHI0);
    cpu->PHI2 = BIT(cpu->PHI0);

    // NMI
    b = NOR ( NOT(cpu->NMI) & cpu->PHI2, cpu->NMIDynaLatch );
    cpu->NMIDynaLatch = NOR ( cpu->NMI & cpu->PHI2, b );
    cpu->FromNMI = NOT(cpu->NMIDynaLatch);

    // IRQ
    b = NOR ( cpu->IRQ & cpu->PHI2, cpu->IRQDynaLatch );
    cpu->IRQDynaLatch = NOR ( NOT(cpu->IRQ) & cpu->PHI2, b);
    if ( cpu->PHI1 ) cpu->IRQStatLatch = cpu->IRQDynaLatch;
    cpu->FromIRQ = NOT(cpu->IRQStatLatch);

    // RDY
    if (cpu->PHI2) cpu->BRLatch[0] = NOT(cpu->RDY);
    if (cpu->PHI1) cpu->BRLatch[1] = NOT(cpu->BRLatch[0]);

    // RES
    b = NOR (cpu->RES & cpu->PHI2, cpu->RESDynaLatch);
    cpu->RESDynaLatch = NOR ( NOT(cpu->RES) & cpu->PHI2, b);
    if ( cpu->PHI1 ) cpu->RESStatLatch = cpu->RESDynaLatch;
    cpu->FromRES = NOT(cpu->RESStatLatch);

    // SO
}
