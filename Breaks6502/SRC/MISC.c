// Top-part input logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void MiscLogic (Context6502 * cpu)
{
    int b;

    // Clock distribution.
    cpu->PHI1 = NOT(cpu->PHI0);
    cpu->PHI2 = BIT(cpu->PHI0);

    // NMI
    b = NOR ( NAND ( NOT(cpu->NMI), cpu->PHI2), cpu->NMIDynaLatch );
    cpu->NMIDynaLatch = NOR ( NAND(cpu->NMI, cpu->PHI2), b );
    cpu->FromNMI = NOT(cpu->NMIDynaLatch);

    // IRQ
    b = NOR ( NAND(cpu->IRQ, cpu->PHI2), cpu->IRQDynaLatch );
    cpu->IRQDynaLatch = NOR ( NAND(NOT(cpu->IRQ), cpu->PHI2), b);
    if ( cpu->PHI1 ) cpu->IRQStatLatch = cpu->IRQDynaLatch;
    cpu->FromIRQ = NOT(cpu->IRQStatLatch);

    // RDY
    if (cpu->PHI2) cpu->BRLatch[0] = BIT(~cpu->RDY);
    if (cpu->PHI1) cpu->BRLatch[1] = BIT(~cpu->BRLatch[0]);

    // RES
    b = ~( ~(cpu->RES & cpu->PHI2) | cpu->RESDynaLatch);
    cpu->RESDynaLatch = BIT( ~(~(NOT(cpu->RES) & cpu->PHI2) | BIT(b)) );
    if ( cpu->PHI1 ) cpu->RESStatLatch = cpu->RESDynaLatch;
    cpu->FromRES = NOT(cpu->RESStatLatch);

    // SO
}
