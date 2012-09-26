// Debug Console.
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <windows.h>

int DebugConsoleOpened = 0;

void OpenDebugConsole (void)
{
    int hConHandle;
    long lStdHandle;
    FILE *fp;

    if ( DebugConsoleOpened ) return;

    AllocConsole ();

    // redirect unbuffered STDOUT to the console
    lStdHandle = (long)GetStdHandle(STD_OUTPUT_HANDLE);
    hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);
    fp = (FILE *)_fdopen( hConHandle, "w" );
    *stdout = *fp;
    setvbuf( stdout, NULL, _IONBF, 0 );

    SetConsoleTitle("Breaks Debug Console");

    DebugConsoleOpened = 1;
}

void CloseDebugConsole (void)
{
    if (!DebugConsoleOpened) return;

    FreeConsole ();

    DebugConsoleOpened = 0;
}

void DPrintf (char *fmt, ...)
{
    if ( DebugConsoleOpened )
    {
        va_list arg;
        char buf[0x1000];

        va_start(arg, fmt);
        vsprintf(buf, fmt, arg);
        va_end(arg);

        printf ("%s", buf);
    }
}
