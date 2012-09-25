#include "Breaks.h"

static ContextBoard nes;

// application message
void Report(char *fmt, ...)
{
    va_list arg;
    char buf[0x1000];

    va_start(arg, fmt);
    vsprintf(buf, fmt, arg);
    va_end(arg);

    MessageBox(NULL, buf, "Breaks Report", MB_ICONINFORMATION | MB_OK | MB_TOPMOST);
}

// We need to hold reset low approx. 80 ms.
// http://www.wilsonminesco.com/6502primer/RSTreqs.html
void PushResetSwitch (void)
{
    nes.ResetCapacitor = 100;       // should be enough :P
}

void PowerOnNES (void)
{
    memset ( &nes, 0, sizeof(nes) );
    nes.cpu.NoDecimalCorrection = 1;

    // Load external libraries
    nes.moduleCPU = LoadLibrary ( "Breaks6502.dll" );
    nes.Step6502 = (void *)GetProcAddress ( nes.moduleCPU, "_Step6502" );
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
    PowerOnNES ();

    // Emulator run-flow
/*
    while (1) StepBoard (&nes);
*/

    Report ( "SHOULD NEVER REACH HERE!" );
    return 0;
}