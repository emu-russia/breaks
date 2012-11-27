// Example emulation run-flow.
//
#include "APU.h"
#include <windows.h>

main ()
{
    DWORD cycles, old;
    ContextAPU apu;
    memset (&apu, 0, sizeof(apu));
    //apu.pad[PPU_nRES] = 1;
    
    cycles = 0;
    old = GetTickCount ();
    while (1) {
        if ( (GetTickCount () - old) >= 1000 ) break;
        APUStep (&apu);
        //apu.pad[APU_CLK] ^= 1;
        cycles++;
    }
    printf ("Executed %.4fM/44M cycles\n", (float)cycles/1000000.0f );
}
