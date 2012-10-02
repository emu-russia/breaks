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

    // RES

    // SO
}
