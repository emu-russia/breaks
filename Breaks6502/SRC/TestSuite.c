#include <stdio.h>
#include "Breaks6502.h"
#include "Breaks6502Private.h"

Context6502 cpu;

// Timing register
// Imitate begaviour of long CPU instruction.
void TimeRegTest (void)
{
    int r = 20, TR;
    int sync = 2;

    while (r--)
    {
        cpu.PHI1 = BIT(~cpu.PHI0);
        cpu.PHI2 = BIT(cpu.PHI0);
        TR = TcountRegister (&cpu, sync > 0, 1, 0);
        printf ( "%02X ", TR );
        cpu.PHI0 ^= 1;
        sync--;
    }

    // Output should be like: 0F 0F 0E 0E 0D 0D 0B 0B 07 07 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F
}

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

// Execute some clocks to reset 6502
void Reset (void)
{
    int r = 100;
    while (r--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }
}

main ()
{
    // Initial conditions
    memset (&cpu, 0, sizeof(cpu));

    TimeRegTest ();
    //ALUTest ();
    //GeneralExecutionTest ( 10000 );
}