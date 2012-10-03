// Top-part input logic
#include "Breaks6502.h"
#include "Breaks6502Private.h"

void MiscLogic (Context6502 * cpu)
{
    // Clock distribution.
    cpu->PHI1 = BIT(~cpu->PHI0);
    cpu->PHI2 = BIT(cpu->PHI0);

    // NMI

    // IRQ

    // RDY
    if (cpu->PHI2) cpu->BRLatch[0] = BIT(~cpu->RDY);
    if (cpu->PHI1) cpu->BRLatch[1] = BIT(~cpu->BRLatch[0]);

    // RES

    // SO
}
