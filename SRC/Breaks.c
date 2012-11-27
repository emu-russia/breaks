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

    //OpenDebugger (&nes);

    //Report ( "SHOULD NEVER REACH HERE!" );
    return 0;
}