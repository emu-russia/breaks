// Motherboard sim.
#include "Breaks.h"

void StepBoard (ContextBoard *board)
{
    // Handle reset switch
    //if (board->ResetCapacitor) board->ResetCapacitor--;
    //board->cpu.RES = (board->ResetCapacitor == 0);

    board->Step6502 ( &board->cpu );
    board->cpu.PHI0 ^= 1;

    //board->Step2A03 ( &board->apu );
    //board->Step2C02 ( &board->ppu );

    // Toggle clock
    //board->apu.CLK ^= 1;
}
