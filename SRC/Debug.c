// Visual debugger.
#include "Breaks.h"
#include "debugconsole.h"

static HWND debug_hwnd;

#define TOGGLE_BUTTON   200

static LRESULT CALLBACK DebugProc (HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch(msg)
    {
        case WM_CREATE:
            debug_hwnd = hwnd;
            return 0;
        case WM_CLOSE:
            DestroyWindow(hwnd);
            return 0;
        case WM_DESTROY:
            exit(1);
            return 0;
        case WM_COMMAND:
            switch (LOWORD(wParam))
            {
                case TOGGLE_BUTTON:
                    Report ( "Toggle clock" );
                    return 0;

            }
            break;
/*
        case WM_PAINT:
            hdc = BeginPaint (hwnd, &ps);
            FillRect (hdc, &whiteBox, whiteBrush);
            FillRect (hdc, &redBox, redBrush);
            FillRect (hdc, &yellowBox, yellowBrush);
            FillRect (hdc, &blueBox, blueBrush);
            EndPaint (hwnd, &ps);
            return 0;
*/
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

static void set_font (HWND ctrl)
{
    static HFONT hFont = NULL;
    if ( hFont == NULL ) {
        hFont = CreateFont (15, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE, ANSI_CHARSET, 
              OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, 
              DEFAULT_PITCH | FF_DONTCARE, TEXT("Calibri"));
    }
    SendMessage(ctrl, WM_SETFONT, (WPARAM)hFont, (LPARAM)TRUE);
}

static void plot_dialog (HINSTANCE hInstance)
{
    WNDCLASS wc;

    wc.cbClsExtra    = wc.cbWndExtra = 0;
    wc.hbrBackground = (HBRUSH)COLOR_BTNSHADOW;
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wc.hIcon         = LoadIcon(NULL, IDI_EXCLAMATION);
    wc.hInstance     = hInstance;
    wc.lpfnWndProc   = DebugProc;
    wc.lpszClassName = "BREAKSDEBUG" "CLASS";
    wc.lpszMenuName  = NULL;
    wc.style         = 0;

    RegisterClass(&wc);

    CreateWindowEx( 0,
                    "BREAKSDEBUG" "CLASS", "Breaks Debug",
                    WS_OVERLAPPED | WS_SYSMENU, 
                    100, 100,
                    600, 180,
                    NULL, NULL,
                    hInstance, NULL );

    set_font ( CreateWindow ("button", "Toggle", WS_CHILD | WS_VISIBLE | BS_CHECKBOX, 10, 45, 110, 40, debug_hwnd, (HMENU)TOGGLE_BUTTON, hInstance, NULL) );
    set_font ( CreateWindow ("button", "Button", WS_CHILD | WS_VISIBLE, 500, 45, 65, 30, debug_hwnd, (HMENU)TOGGLE_BUTTON, hInstance, NULL) );

    ShowWindow (debug_hwnd, SW_NORMAL);
    UpdateWindow (debug_hwnd);
}

// Fall back to debug mode.
void OpenDebugger (ContextBoard *nes)
{
    OpenDebugConsole ();
    DPrintf ("Debug console opened\n");

    plot_dialog ( GetModuleHandle(NULL) );
    while (1) {
        MSG msg;
        while (PeekMessage (&msg, NULL, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }
}
