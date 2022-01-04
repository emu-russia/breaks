// Example emulation run-flow.
//
#include "APU.h"
#include <windows.h>

/*
main ()
{
    DWORD cycles, oldcycles, old;
    ContextAPU apu;
    memset (&apu, 0, sizeof(apu));
    apu.pad[APU_nRES] = 1;
    apu.pad[APU_nIRQ] = 1;
    apu.pad[APU_nNMI] = 1;

    cycles = oldcycles = 0;
    old = GetTickCount ();
    while (1) {
        //if ( (GetTickCount () - old) >= 1000 ) break;
        if ( cycles >= 1800000 ) break;

        APUStep (&apu);
        //apu.pad[APU_CLK] ^= 1;

        //printf ("%i %i %i\n", apu.ctrl[APU_CTRL_ACLK], apu.ctrl[APU_CTRL_LFO1], apu.ctrl[APU_CTRL_LFO2] );
        if ( apu.ctrl[APU_CTRL_LFO2] == 0 ) {
            printf ( "clk: %i, delta:%i, LFO1:%i, LFO2:%i\n", cycles, cycles-oldcycles, apu.ctrl[APU_CTRL_LFO1], apu.ctrl[APU_CTRL_LFO2] );
            oldcycles = cycles;
        }

        apu.ctrl[APU_CTRL_PHI0] ^= 1;
        cycles++;
    }
    //printf ("Executed %.4fM/44M cycles\n", (float)cycles/1000000.0f );
}
*/