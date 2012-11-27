// Example emulation run-flow.
//
#include "PPU.h"
#include <windows.h>

main ()
{
    DWORD cycles, old;
    ContextPPU ppu;
    memset (&ppu, 0, sizeof(ppu));
    ppu.pad[PPU_nRES] = 1;

    // setup some PPU controls
    ppu.ctrl[PPU_CTRL_BLACK] = 0;
    ppu.ctrl[PPU_CTRL_OBCLIP] = 1;
    ppu.ctrl[PPU_CTRL_BGCLIP] = 1;
    
    cycles = 0;
    old = GetTickCount ();
    while (1) {
        //if ( (GetTickCount () - old) >= 1000 ) break;
        PPUStep (&ppu);
        ppu.pad[PPU_CLK] ^= 1;
        cycles++;
    }
    printf ("Executed %.4fM/44M cycles\n", (float)cycles/1000000.0f );
}
