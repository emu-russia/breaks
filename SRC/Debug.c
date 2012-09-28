// Visual debugger.
#include "Breaks.h"

#include "debugconsole.h"
#include "PLANames.h"

static HWND debug_hwnd;
static ContextBoard *DebugNES;

HPEN linePen;

enum {
    DEBUG_CONTROLS_BASE = 200,
    STEP_BUTTON,

    VAL_ADDR, VAL_X, VAL_Y, VAL_S, VAL_SB, VAL_DB,
    VAL_ADH, VAL_ADL,
    VAL_AI, VAL_BI, VAL_ADD, VAL_AC,
    VAL_PCL, VAL_PCH, VAL_PCLS, VAL_PCHS,
    VAL_DL, VAL_DOR, VAL_DATA,

    DRV_ADH_ABH, DRV_ADL_ABL, DRV_0_ADL0, DRV_0_ADL1, DRV_0_ADL2,

    DRV_Y_SB, DRV_X_SB, DRV_SB_Y, DRV_SB_X, DRV_S_SB, DRV_S_ADL, DRV_SB_S, DRV_S_S,

    DRV_ADH_PCH, DRV_PCH_PCH, DRV_PCH_DB,
    DRV_PCL_DB, DRV_PCH_ADH, DRV_PCL_PCL,
    DRV_PCL_ADL, DRV_ADL_PCL, DRV_IPC,

    DRV_DL_ADL, DRV_DL_ADH, DRV_DL_DB,

    DRV_nDB_ADD, DRV_DB_ADD, DRV_0_ADD, DRV_SB_ADD, DRV_ADL_ADD,
    DRV_ANDS, DRV_EORS, DRV_ORS, DRV_I_ADDC, DRV_SRS,
    DRV_SUMS, DRV_DAA, DRV_ADD_SB7, DRV_ADD_SB06, DRV_ADD_ADL,
    DRV_DSA, DRV_0_ADH0, DRV_SB_DB, DRV_SB_AC, DRV_SB_ADH,
    DRV_0_ADH17, DRV_AC_SB, DRV_AC_DB,

    PLA_BASE = 300,
    PLA_MAX = 430,

    DEBUG_CONTROLS_MAX
};

static  HWND debugCtrl[DEBUG_CONTROLS_MAX];

static void update_debugger (ContextBoard *nes);

static LRESULT CALLBACK DebugProc (HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;

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
                case STEP_BUTTON:
                    update_debugger (DebugNES);
                    return 0;
            }
            break;

        case WM_PAINT:      // Draw lines around controls
            hdc = BeginPaint (hwnd, &ps);
            SelectObject (hdc, linePen );

            MoveToEx (hdc, 125, 5, NULL);
            LineTo (hdc, 125, 475);
            MoveToEx (hdc, 295, 5, NULL);
            LineTo (hdc, 295, 475);
            MoveToEx (hdc, 400, 5, NULL);
            LineTo (hdc, 400, 475);

            MoveToEx (hdc, 5, 110, NULL);
            LineTo (hdc, 125, 110);

            MoveToEx (hdc, 5, 210, NULL);
            LineTo (hdc, 125, 210);

            EndPaint (hwnd, &ps);
            return 0;

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

static void bold_font (HWND ctrl)
{
    static HFONT hFont = NULL;
    if ( hFont == NULL ) {
        hFont = CreateFont (15, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, ANSI_CHARSET, 
              OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, 
              DEFAULT_PITCH | FF_DONTCARE, TEXT("Calibri"));
    }
    SendMessage(ctrl, WM_SETFONT, (WPARAM)hFont, (LPARAM)TRUE);
}

static void label ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text )
{
    bold_font ( CreateWindow ("static", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 60, 14, dlg, (HMENU)0, hInstance, NULL) );
}
static void label_long ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text )
{
    bold_font ( CreateWindow ("static", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 90, 14, dlg, (HMENU)0, hInstance, NULL) );
}
static HWND value ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text, int id )
{
    HWND hwnd = CreateWindow ("static", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 25, 14, dlg, (HMENU)id, hInstance, NULL);
    set_font ( hwnd );
    return hwnd;
}
static HWND toggle ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text, int id )
{
    HWND hwnd = CreateWindow ("button", text, WS_CHILD | WS_VISIBLE | BS_CHECKBOX, x, y, 70, 14, dlg, (HMENU)id, hInstance, NULL);
    bold_font (hwnd);
    return hwnd;
}

static void place_controls (HINSTANCE hinst, HWND dlg)
{
    int y, i;

    // Registers section
    label (hinst, dlg, 12, 8, "ADDR" );
    debugCtrl[VAL_ADDR] = value (hinst, dlg, 44, 8, "1234", VAL_ADDR );

    y = 15;
    label (hinst, dlg, 12, y+=15, "X" );
    label (hinst, dlg, 12, y+=15, "Y" );
    label (hinst, dlg, 12, y+=15, "S" );
    y = 15;
    debugCtrl[VAL_X] = value (hinst, dlg, 25, y+=15, "12", VAL_X );
    debugCtrl[VAL_Y] = value (hinst, dlg, 25, y+=15, "34", VAL_Y );
    debugCtrl[VAL_S] = value (hinst, dlg, 25, y+=15, "56", VAL_S );

    y = 15;
    label (hinst, dlg, 52, y+=15, "SB" );
    label (hinst, dlg, 52, y+=15, "DB" );
    y+=15;
    label (hinst, dlg, 52, y+=15, "ADH" );
    label (hinst, dlg, 52, y+=15, "ADL" );
    y = 15;
    debugCtrl[VAL_SB] = value (hinst, dlg, 78, y+=15, "12", VAL_SB );
    debugCtrl[VAL_DB] = value (hinst, dlg, 78, y+=15, "12", VAL_DB );
    y+=15;
    debugCtrl[VAL_ADH] = value (hinst, dlg, 78, y+=15, "12", VAL_ADH );
    debugCtrl[VAL_ADL] = value (hinst, dlg, 78, y+=15, "12", VAL_ADL );

    y = 100;
    label (hinst, dlg, 12, y+=15, "ALU" );
    y+=15;
    label (hinst, dlg, 12, y+=15, "AI" );
    label (hinst, dlg, 12, y+=15, "BI" );
    label (hinst, dlg, 12, y+=15, "ADD" );
    label (hinst, dlg, 12, y+=15, "AC" );
    y = 100 + 30;
    debugCtrl[VAL_AI] = value (hinst, dlg, 38, y+=15, "12", VAL_AI );
    debugCtrl[VAL_BI] = value (hinst, dlg, 38, y+=15, "12", VAL_BI );
    debugCtrl[VAL_ADD] = value (hinst, dlg, 38, y+=15, "12", VAL_ADD );
    debugCtrl[VAL_AC] = value (hinst, dlg, 38, y+=15, "12", VAL_AC );

    y = 200;
    label (hinst, dlg, 12, y+=15, "PCL" );
    label (hinst, dlg, 12, y+=15, "PCH" );
    y+=15;
    label (hinst, dlg, 12, y+=15, "DL" );
    label (hinst, dlg, 12, y+=15, "DOR" );
    y+=15;
    label (hinst, dlg, 12, y+=15, "DATA" );
    y = 200;
    debugCtrl[VAL_PCL] = value (hinst, dlg, 38, y+=15, "12", VAL_PCL );
    debugCtrl[VAL_PCH] = value (hinst, dlg, 38, y+=15, "12", VAL_PCH );
    y+=15;
    debugCtrl[VAL_DL] = value (hinst, dlg, 38, y+=15, "12", VAL_DL );
    debugCtrl[VAL_DOR] = value (hinst, dlg, 38, y+=15, "12", VAL_DOR );
    y+=15;
    debugCtrl[VAL_DATA] = value (hinst, dlg, 42, y+=15, "12", VAL_DATA );

    y = 200;
    label (hinst, dlg, 64, y+=15, "PCLS" );
    label (hinst, dlg, 64, y+=15, "PCHS" );
    y = 200;
    debugCtrl[VAL_PCLS] = value (hinst, dlg, 98, y+=15, "12", VAL_PCLS );
    debugCtrl[VAL_PCHS] = value (hinst, dlg, 98, y+=15, "12", VAL_PCHS );

    // Drivers
    y = 15;
    label (hinst, dlg, 135, 8, "Drivers" );
    debugCtrl[DRV_ADH_ABH] = toggle (hinst, dlg, 135, y+=15, "ADH/ABH", DRV_ADH_ABH );
    debugCtrl[DRV_ADL_ABL] = toggle (hinst, dlg, 135, y+=15, "ADL/ABL", DRV_ADL_ABL );
    debugCtrl[DRV_0_ADL0] = toggle (hinst, dlg, 135, y+=15, "0/ADL0", DRV_0_ADL0 );
    debugCtrl[DRV_0_ADL1] = toggle (hinst, dlg, 135, y+=15, "0/ADL1", DRV_0_ADL1 );
    debugCtrl[DRV_0_ADL2] = toggle (hinst, dlg, 135, y+=15, "0/ADL2", DRV_0_ADL2 );

    y += 15;
    debugCtrl[DRV_Y_SB] = toggle (hinst, dlg, 135, y+=15, "Y/SB", DRV_Y_SB );
    debugCtrl[DRV_X_SB] = toggle (hinst, dlg, 135, y+=15, "X/SB", DRV_X_SB );
    debugCtrl[DRV_SB_Y] = toggle (hinst, dlg, 135, y+=15, "SB/Y", DRV_SB_Y );
    debugCtrl[DRV_SB_X] = toggle (hinst, dlg, 135, y+=15, "SB/X", DRV_SB_X );
    debugCtrl[DRV_S_SB] = toggle (hinst, dlg, 135, y+=15, "S/SB", DRV_S_SB );
    debugCtrl[DRV_S_ADL] = toggle (hinst, dlg, 135, y+=15, "S/ADL", DRV_S_ADL );
    debugCtrl[DRV_SB_S] = toggle (hinst, dlg, 135, y+=15, "SB/S", DRV_SB_S );
    debugCtrl[DRV_S_S] = toggle (hinst, dlg, 135, y+=15, "S/S", DRV_S_S );

    y += 15;
    debugCtrl[DRV_ADH_PCH] = toggle (hinst, dlg, 135, y+=15, "ADH/PCH", DRV_ADH_PCH );
    debugCtrl[DRV_PCH_PCH] = toggle (hinst, dlg, 135, y+=15, "PCH/PCH", DRV_PCH_PCH );
    debugCtrl[DRV_PCH_DB] = toggle (hinst, dlg, 135, y+=15, "PCH/DB", DRV_PCH_DB );
    debugCtrl[DRV_PCL_DB] = toggle (hinst, dlg, 135, y+=15, "PCL/DB", DRV_PCL_DB );
    debugCtrl[DRV_PCH_ADH] = toggle (hinst, dlg, 135, y+=15, "PCH/ADH", DRV_PCH_ADH );
    debugCtrl[DRV_PCL_PCL] = toggle (hinst, dlg, 135, y+=15, "PCL/PCL", DRV_PCL_PCL );
    debugCtrl[DRV_PCL_ADL] = toggle (hinst, dlg, 135, y+=15, "PCL/ADL", DRV_PCL_ADL );
    debugCtrl[DRV_ADL_PCL] = toggle (hinst, dlg, 135, y+=15, "ADL/PCL", DRV_ADL_PCL );
    debugCtrl[DRV_IPC] = toggle (hinst, dlg, 135, y+=15, "IPC", DRV_IPC );

    y += 15;
    debugCtrl[DRV_DL_ADL] = toggle (hinst, dlg, 135, y+=15, "DL/ADL", DRV_DL_ADL );
    debugCtrl[DRV_DL_ADH] = toggle (hinst, dlg, 135, y+=15, "DL/ADH", DRV_DL_ADH );
    debugCtrl[DRV_DL_DB] = toggle (hinst, dlg, 135, y+=15, "DL/DB", DRV_DL_DB );

    y = 15;
    debugCtrl[DRV_nDB_ADD] = toggle (hinst, dlg, 220, y+=15, "~DB/ADD", DRV_nDB_ADD );
    debugCtrl[DRV_DB_ADD] = toggle (hinst, dlg, 220, y+=15, "DB/ADD", DRV_DB_ADD );
    debugCtrl[DRV_0_ADD] = toggle (hinst, dlg, 220, y+=15, "0/ADD", DRV_0_ADD );
    debugCtrl[DRV_SB_ADD] = toggle (hinst, dlg, 220, y+=15, "SB/ADD", DRV_SB_ADD );
    debugCtrl[DRV_ADL_ADD] = toggle (hinst, dlg, 220, y+=15, "ADL/ADD", DRV_ADL_ADD );
    debugCtrl[DRV_ANDS] = toggle (hinst, dlg, 220, y+=15, "ANDS", DRV_ANDS );
    debugCtrl[DRV_EORS] = toggle (hinst, dlg, 220, y+=15, "EORS", DRV_EORS );
    debugCtrl[DRV_ORS] = toggle (hinst, dlg, 220, y+=15, "ORS", DRV_ORS );
    debugCtrl[DRV_I_ADDC] = toggle (hinst, dlg, 220, y+=15, "I_ADDC", DRV_I_ADDC );
    debugCtrl[DRV_SRS] = toggle (hinst, dlg, 220, y+=15, "SRS", DRV_SRS );
    debugCtrl[DRV_SUMS] = toggle (hinst, dlg, 220, y+=15, "SUMS", DRV_SUMS );
    debugCtrl[DRV_DAA] = toggle (hinst, dlg, 220, y+=15, "DAA", DRV_DAA );
    debugCtrl[DRV_ADD_SB7] = toggle (hinst, dlg, 220, y+=15, "ADD/SB7", DRV_ADD_SB7 );
    debugCtrl[DRV_ADD_SB06] = toggle (hinst, dlg, 220, y+=15, "ADD/SB06", DRV_ADD_SB06 );
    debugCtrl[DRV_ADD_ADL] = toggle (hinst, dlg, 220, y+=15, "ADD/ADL", DRV_ADD_ADL );
    debugCtrl[DRV_DSA] = toggle (hinst, dlg, 220, y+=15, "DSA", DRV_DSA );
    debugCtrl[DRV_0_ADH0] = toggle (hinst, dlg, 220, y+=15, "0/ADH0", DRV_0_ADH0 );
    debugCtrl[DRV_SB_DB] = toggle (hinst, dlg, 220, y+=15, "SB/DB", DRV_SB_DB );
    debugCtrl[DRV_SB_AC] = toggle (hinst, dlg, 220, y+=15, "SB/AC", DRV_SB_AC );
    debugCtrl[DRV_SB_ADH] = toggle (hinst, dlg, 220, y+=15, "SB/ADH", DRV_SB_ADH );
    debugCtrl[DRV_0_ADH17] = toggle (hinst, dlg, 220, y+=15, "0/ADH17", DRV_0_ADH17 );
    debugCtrl[DRV_AC_SB] = toggle (hinst, dlg, 220, y+=15, "AC/SB", DRV_AC_SB );
    debugCtrl[DRV_AC_DB] = toggle (hinst, dlg, 220, y+=15, "AC/DB", DRV_AC_DB );

    // Random logic latches and signals
    y = 15;
    label_long (hinst, dlg, 305, 8, "Random Logic" );
    toggle (hinst, dlg, 305, y+=15, "Latch 1", 0 );
    toggle (hinst, dlg, 305, y+=15, "Latch 2", 0 );
    toggle (hinst, dlg, 305, y+=15, "Latch 3", 0 );

    // PLA
    label_long (hinst, dlg, 410, 50, "PLA" );
    for (y=60,i=0; i<6; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 410, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<21; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 490, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<37; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 570, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<54; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 650, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<73; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 730, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<91; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 810, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<104; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 890, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<120; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 970, y+=15, PLAName(i), PLA_BASE+i );
    for (y=60; i<129; i++) debugCtrl[PLA_BASE+i] = toggle (hinst, dlg, 1050, y+=15, PLAName(i), PLA_BASE+i );

    set_font ( CreateWindow ("button", "Step", WS_CHILD | WS_VISIBLE, 880, 430, 80, 30, dlg, (HMENU)STEP_BUTTON, hinst, NULL) );
}

static void update_debugger (ContextBoard *nes)
{
}

static void plot_dialog (HINSTANCE hInstance)
{
    WNDCLASS wc;
    HDC hdc;

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
                    "BREAKSDEBUG" "CLASS", "Breaks Debug 6502",
                    WS_OVERLAPPED | WS_SYSMENU, 
                    CW_USEDEFAULT, CW_USEDEFAULT,
                    1150, 500,
                    NULL, NULL,
                    hInstance, NULL );

    place_controls (hInstance, debug_hwnd);
    update_debugger (DebugNES);

    ShowWindow (debug_hwnd, SW_NORMAL);
    UpdateWindow (debug_hwnd);
}

// Fall back to debug mode.
void OpenDebugger (ContextBoard *nes)
{
    OpenDebugConsole ();
    DPrintf ("Debug console opened\n");

    linePen = CreatePen (PS_SOLID, 2, RGB(125,125,125) );

    DebugNES = nes;

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
