#include "Breaks.h"

static ContextBoard nes;

#ifdef _WINDOWS        // Visual studio
#define DLL_PREFIX
#else       // lcc adding _ prefix to exported DLL names
#define DLL_PREFIX "_"
#endif

// fatal error
void Error(char *fmt, ...)
{
    va_list arg;
    char buf[0x1000];

    va_start(arg, fmt);
    vsprintf(buf, fmt, arg);
    va_end(arg);

    MessageBox(NULL, buf, "Breaks Broken", MB_ICONHAND | MB_OK | MB_TOPMOST);

    exit(0);    // return bad
}

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
    nes.cpu.DEBUG = 1;

    // Load external libraries
    nes.moduleCPU = LoadLibrary ( "Breaks6502.dll" );
    nes.Step6502 = (void (*)(Context6502 *))GetProcAddress ( nes.moduleCPU, DLL_PREFIX "Step6502" );
    nes.Debug6502 = (void (*)(Context6502 *, char *))GetProcAddress ( nes.moduleCPU, DLL_PREFIX "Debug6502" );
    if ( nes.Step6502 == NULL || nes.Debug6502 == NULL ) Error ("No CPU module");

    nes.moduleAPU = LoadLibrary ( "Ricoh2A03.dll" );
    nes.Step2A03 = (void (*)(Context2A03 *))GetProcAddress ( nes.moduleAPU, DLL_PREFIX "Step2A03" );
    nes.Debug2A03 = (void (*)(Context2A03 *, char *))GetProcAddress ( nes.moduleAPU, DLL_PREFIX "Debug2A03" );
    if ( nes.Step2A03 == NULL || nes.Debug2A03 == NULL ) Error ("No APU module");

    nes.modulePPU = LoadLibrary ( "Ricoh2C02.dll" );
    nes.Step2C02 = (void (*)(Context2C02 *))GetProcAddress ( nes.modulePPU, DLL_PREFIX "Step2C02" );
    nes.Debug2C02 = (void (*)(Context2C02 *, char *))GetProcAddress ( nes.modulePPU, DLL_PREFIX "Debug2C02" );
    if ( nes.Step2C02 == NULL || nes.Debug2C02 == NULL ) Error ("No PPU module");

    // Attach 6502 to APU.
    nes.apu.cpu = (Core6502 *)&nes.cpu;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
    DWORD cycles, old;

    PowerOnNES ();
    //ConnectTV (&nes);

    // Emulator run-flow
/*
    while (1) StepBoard (&nes);
*/

    cycles = 0;
    old = GetTickCount ();
    while (1) {
        if ( (GetTickCount () - old) >= 1000 ) break;
        StepBoard (&nes);
        cycles++;
    }
    Report ("Executed %i cycles", cycles );

//    OpenDebugger (&nes);

    //Report ( "SHOULD NEVER REACH HERE!" );
    return 0;
}