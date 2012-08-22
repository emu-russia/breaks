#include "Breaks6502Private.h"

void Step6502 ( Context6502 * cpu )
{
    // Clock distribution.

    cpu->PHI1 = BIT(~cpu->PHI0);
    cpu->PHI2 = BIT(cpu->PHI0);


}