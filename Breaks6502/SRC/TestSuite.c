#include <stdio.h>
#include "Breaks6502.h"

Context6502 cpu;

// http://visual6502.org/wiki/index.php?title=6502DecimalMode
void ALUTest (void)
{
}

void GeneralExecutionTest (i)
{
    // Execute given amount of clock iterations
    while (i--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }
}

main ()
{
    int r = 100;

    // Initial conditions
    cpu.PHI0 = 0;

    // Execute some clocks to reset 6502
    while (r--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }

    ALUTest ();
    //GeneralExecutionTest ( 10000 );
}