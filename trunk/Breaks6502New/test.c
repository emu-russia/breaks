// Example emulation run-flow.
#include "6502.h"
#include <windows.h>

// Push random data
// TODO: Add infinite cycle test program.
static void DummyMemoryDevice (ContextM6502 *cpu)
{
    if ( cpu->pads[M6502_PAD_PHI2] ) cpu->pad[M6502_PAD_DATA] = rand() & 0xff; 
}

main ()
{
    DWORD old;
    ContextM6502 cpu;
    memset (&cpu, 0, sizeof(cpu));

    // default conditions (no interrupts, no reset, 6502 ready)
    cpu.pad[M6502_PAD_nNMI] = 1;
    cpu.pad[M6502_PAD_nIRQ] = 1;
    cpu.pad[M6502_PAD_nRES] = 1;
    cpu.pad[M6502_PAD_RDY] = 1;

    cpu.debug[M6502_DEBUG_OUT] = 1;

    // Execute virtual 1 second.
    srand ( 0xaabb );
    old = GetTickCount ();
    while (1) {
        if ( (GetTickCount () - old) >= 1000 ) break;
        M6502Step (&cpu);
        DummyMemoryDevice (&cpu);
        cpu.pad[M6502_PAD_PHI0] ^= 1;
    }
    printf ("Executed %.4fM/4M cycles\n", (float)cpu.debug[M6502_DEBUG_CLKCOUNT]/1000000.0f );
}
