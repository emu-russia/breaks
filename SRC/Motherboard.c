// Motherboard sim.
#include "Breaks.h"

void StepBoard (ContextBoard *board)
{
    // Handle reset switch
    if (board->ResetCapacitor) board->ResetCapacitor--;
    board->cpu.RES = (board->ResetCapacitor == 0);

    board->Step6502 ( &board->cpu );

    // Toggle clock
    board->cpu.PHI0 ^= 1;
}
