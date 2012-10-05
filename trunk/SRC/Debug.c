// Visual debugger.
#include "Breaks.h"
#include "DebugUtils.h"

static HWND debug_hwnd;
static ContextBoard *DebugNES;

static  HPEN linePen;
static  int PlotDone = 0;

enum {
    DEBUG_CONTROLS_BASE = 200,
    STEP_BUTTON,

    MISC_BUTTON, TSTEP_BUTTON, IR_BUTTON, PLA_BUTTON, PREDECODE_BUTTON,
    RANDOM1_BUTTON, RANDOM2_BUTTON, ALU_BUTTON, DATA_BUTTON, REGS_BUTTON,
    PC_BUTTON, ADDR_BUTTON,

    VAL_ADDR, VAL_X, VAL_Y, VAL_S, VAL_SB, VAL_DB,
    VAL_ABH, VAL_ABL, VAL_ADH, VAL_ADL,
    VAL_AI, VAL_BI, VAL_ADD, VAL_AC,
    VAL_PCL, VAL_PCH, VAL_PCLS, VAL_PCHS,
    VAL_DL, VAL_DOR, VAL_DATA,
    VAL_PD, VAL_IR, VAL_DISA, VAL_MODE,

    LATCH_TRSYNC, LINE_T2, LINE_T3, LINE_T4, LINE_T5, 
    LINE_PHI0, LINE_PHI1, LINE_PHI2, 
    LINE_NMI, LINE_FROMNMI,
    LINE_IRQ, LINE_FROMIRQ,
    LINE_RDY, LATCH_BR0, LATCH_BR1, 
    LINE_RES, LINE_FROMRES,
    LINE_SO, LINE_FROMSO, LATCH_SO0, LATCH_SO1, LATCH_SO2, 

    // Random logic latches and control lines.
    LATCH_nREADY,
    LINE_SYNC,

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

    PLA_BASE = 400,
    PLA_MAX = 530,

    DEBUG_CONTROLS_MAX
};

static  HWND debugCtrl[DEBUG_CONTROLS_MAX];

static void update_debugger (ContextBoard *nes);

static void process_edit ( WPARAM wParam, int ctrl)
{
    Context6502 *cpu = &DebugNES->cpu;
    unsigned char val;
    char text[256];
    if (HIWORD(wParam) == EN_CHANGE && LOWORD(wParam) == ctrl && PlotDone) {
        SendMessage ( debugCtrl[ctrl], WM_GETTEXT, (WPARAM)sizeof(text), (LPARAM)text);
        val = strtoul (text, NULL, 16) & 0xff;
        switch (ctrl)
        {
            case VAL_X: unpackreg (cpu->X, val, 8); break;
            case VAL_Y: unpackreg (cpu->Y, val, 8); break;
            case VAL_S: unpackreg (cpu->S, val, 8); break;
            case VAL_SB: unpackreg (cpu->SB, val, 8); break;
            case VAL_DB: unpackreg (cpu->DB, val, 8); break;
            case VAL_ABH: unpackreg (cpu->ABH, val, 8); break;
            case VAL_ABL: unpackreg (cpu->ABL, val, 8); break;
            case VAL_ADH: unpackreg (cpu->ADH, val, 8); break;
            case VAL_ADL: unpackreg (cpu->ADL, val, 8); break;
            case VAL_AI: unpackreg (cpu->AI, val, 8); break;
            case VAL_BI: unpackreg (cpu->BI, val, 8); break;
            case VAL_ADD: unpackreg (cpu->ADD, val, 8); break;
            case VAL_AC: unpackreg (cpu->AC, val, 8); break;
            case VAL_PCL: unpackreg (cpu->PCL, val, 8); break;
            case VAL_PCH: unpackreg (cpu->PCH, val, 8); break;
            case VAL_PCLS: unpackreg (cpu->PCLS, val, 8); break;
            case VAL_PCHS: unpackreg (cpu->PCHS, val, 8); break;
            case VAL_DL: unpackreg (cpu->DL, val, 8); break;
            case VAL_DOR: unpackreg (cpu->DOR, val, 8); break;
            case VAL_DATA: unpackreg (cpu->DATA, val, 8); break;
            case VAL_PD: unpackreg (cpu->PD, val, 8); break;
            case VAL_IR:
                unpackreg (cpu->IR, val, 8);
                break;
        }
    }
}

static void process_check ( WPARAM wParam, int ctrl)
{
    Context6502 *cpu = &DebugNES->cpu;
    char value;
    if ( LOWORD(wParam) == ctrl && PlotDone ) {
        value = SendMessage (debugCtrl[ctrl], BM_GETCHECK, 0, 0) == BST_CHECKED ? 0 : 1;
        switch (ctrl) {
            case LATCH_TRSYNC: cpu->TRSync = value; break;
            case LINE_PHI0: cpu->PHI0 = value; break;
            case LINE_PHI1: cpu->PHI1 = value; break;
            case LINE_PHI2: cpu->PHI2 = value; break;
            case LINE_NMI: cpu->NMI = value; break;
            case LINE_FROMNMI: cpu->FromNMI = value; break;
            case LINE_IRQ: cpu->IRQ = value; break;
            case LINE_FROMIRQ: cpu->FromIRQ = value; break;
            case LINE_RDY: cpu->RDY = value; break;
            case LATCH_BR0: cpu->BRLatch[0] = value; break;
            case LATCH_BR1: cpu->BRLatch[1] = value; break;
            case LINE_RES: cpu->RES = value; break;
            case LINE_FROMRES: cpu->FromRES = value; break;
            case LINE_SO: cpu->SO = value; break;
            case LINE_FROMSO: cpu->FromSO = value; break;
            case LATCH_SO0: cpu->SOLatch[0] = value; break;
            case LATCH_SO1: cpu->SOLatch[1] = value; break;
            case LATCH_SO2: cpu->SOLatch[2] = value; break;

            case DRV_ADH_ABH: cpu->DRIVEREG[DRIVE_ADH_ABH] = value; break;
            case DRV_ADL_ABL: cpu->DRIVEREG[DRIVE_ADL_ABL] = value; break;
            case DRV_0_ADL0: cpu->DRIVEREG[DRIVE_0_ADL0] = value; break;
            case DRV_0_ADL1: cpu->DRIVEREG[DRIVE_0_ADL1] = value; break;
            case DRV_0_ADL2: cpu->DRIVEREG[DRIVE_0_ADL2] = value; break;

            case DRV_Y_SB: cpu->DRIVEREG[DRIVE_Y_SB] = value; break;
            case DRV_X_SB: cpu->DRIVEREG[DRIVE_X_SB] = value; break;
            case DRV_SB_Y: cpu->DRIVEREG[DRIVE_SB_Y] = value; break;
            case DRV_SB_X: cpu->DRIVEREG[DRIVE_SB_X] = value; break;
            case DRV_S_SB: cpu->DRIVEREG[DRIVE_S_SB] = value; break;
            case DRV_S_ADL: cpu->DRIVEREG[DRIVE_S_ADL] = value; break;
            case DRV_SB_S: cpu->DRIVEREG[DRIVE_SB_S] = value; break;
            case DRV_S_S: cpu->DRIVEREG[DRIVE_S_S] = value; break;

            case DRV_nDB_ADD: cpu->DRIVEREG[DRIVE_NOTDB_ADD] = value; break;
            case DRV_DB_ADD: cpu->DRIVEREG[DRIVE_DB_ADD] = value; break;
            case DRV_0_ADD: cpu->DRIVEREG[DRIVE_0_ADD] = value; break;
            case DRV_SB_ADD: cpu->DRIVEREG[DRIVE_SB_ADD] = value; break;
            case DRV_ADL_ADD: cpu->DRIVEREG[DRIVE_ADL_ADD] = value; break;
            case DRV_ANDS: cpu->DRIVEREG[DRIVE_ANDS] = value; break;
            case DRV_EORS: cpu->DRIVEREG[DRIVE_EORS] = value; break;
            case DRV_ORS: cpu->DRIVEREG[DRIVE_ORS] = value; break;
            case DRV_I_ADDC: cpu->DRIVEREG[DRIVE_I_ADDC] = value; break;
            case DRV_SRS: cpu->DRIVEREG[DRIVE_SRS] = value; break;
            case DRV_SUMS: cpu->DRIVEREG[DRIVE_SUMS] = value; break;
            case DRV_DAA: cpu->DRIVEREG[DRIVE_DAA] = value; break;
            case DRV_ADD_SB7: cpu->DRIVEREG[DRIVE_ADD_SB7] = value; break;
            case DRV_ADD_SB06: cpu->DRIVEREG[DRIVE_ADD_SB06] = value; break;
            case DRV_ADD_ADL: cpu->DRIVEREG[DRIVE_ADD_ADL] = value; break;
            case DRV_DSA: cpu->DRIVEREG[DRIVE_DSA] = value; break;
            case DRV_0_ADH0: cpu->DRIVEREG[DRIVE_0_ADH0] = value; break;
            case DRV_SB_DB: cpu->DRIVEREG[DRIVE_SB_DB] = value; break;
            case DRV_SB_AC: cpu->DRIVEREG[DRIVE_SB_AC] = value; break;
            case DRV_SB_ADH: cpu->DRIVEREG[DRIVE_SB_ADH] = value; break;
            case DRV_0_ADH17: cpu->DRIVEREG[DRIVE_0_ADH17] = value; break;
            case DRV_AC_SB: cpu->DRIVEREG[DRIVE_AC_SB] = value; break;
            case DRV_AC_DB: cpu->DRIVEREG[DRIVE_AC_DB] = value; break;

            case DRV_ADH_PCH: cpu->DRIVEREG[DRIVE_ADH_PCH] = value; break;
            case DRV_PCH_PCH: cpu->DRIVEREG[DRIVE_PCH_PCH] = value; break;
            case DRV_PCH_DB: cpu->DRIVEREG[DRIVE_PCH_DB] = value; break;
            case DRV_PCL_DB: cpu->DRIVEREG[DRIVE_PCL_DB] = value; break;
            case DRV_PCH_ADH: cpu->DRIVEREG[DRIVE_PCH_ADH] = value; break;
            case DRV_PCL_PCL: cpu->DRIVEREG[DRIVE_PCL_PCL] = value; break;
            case DRV_PCL_ADL: cpu->DRIVEREG[DRIVE_PCL_ADL] = value; break;
            case DRV_ADL_PCL: cpu->DRIVEREG[DRIVE_ADL_PCL] = value; break;
            case DRV_IPC: cpu->DRIVEREG[DRIVE_IPC] = value; break;

            case DRV_DL_ADL: cpu->DRIVEREG[DRIVE_DL_ADL] = value; break;
            case DRV_DL_ADH: cpu->DRIVEREG[DRIVE_DL_ADH] = value; break;
            case DRV_DL_DB: cpu->DRIVEREG[DRIVE_DL_DB] = value; break;
        }

        if ( ctrl >= PLA_BASE )  cpu->PLAOUT[ctrl-PLA_BASE] = value;

        SendMessage (debugCtrl[ctrl], BM_SETCHECK, value ? BST_CHECKED : BST_UNCHECKED, 0);
    }
}

static LRESULT CALLBACK DebugProc (HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;
    int i;

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

            process_edit (wParam, VAL_X);
            process_edit (wParam, VAL_Y);
            process_edit (wParam, VAL_S);
            process_edit (wParam, VAL_SB);
            process_edit (wParam, VAL_DB);
            process_edit (wParam, VAL_ABH);
            process_edit (wParam, VAL_ABL);
            process_edit (wParam, VAL_ADH);
            process_edit (wParam, VAL_ADL);
            process_edit (wParam, VAL_AI);
            process_edit (wParam, VAL_BI);
            process_edit (wParam, VAL_ADD);
            process_edit (wParam, VAL_AC);
            process_edit (wParam, VAL_PCL);
            process_edit (wParam, VAL_PCH);
            process_edit (wParam, VAL_PCLS);
            process_edit (wParam, VAL_PCHS);
            process_edit (wParam, VAL_DL);
            process_edit (wParam, VAL_DOR);
            process_edit (wParam, VAL_DATA);
            process_edit (wParam, VAL_PD);
            process_edit (wParam, VAL_IR);

            process_check (wParam,  DRV_ADH_ABH);
            process_check (wParam,  DRV_ADL_ABL);
            process_check (wParam,  DRV_0_ADL0);
            process_check (wParam,  DRV_0_ADL1);
            process_check (wParam,  DRV_0_ADL2);

            process_check (wParam,  DRV_Y_SB);
            process_check (wParam,  DRV_X_SB);
            process_check (wParam,  DRV_SB_Y);
            process_check (wParam,  DRV_SB_X);
            process_check (wParam,  DRV_S_SB);
            process_check (wParam,  DRV_S_ADL);
            process_check (wParam,  DRV_SB_S);
            process_check (wParam,  DRV_S_S);

            process_check (wParam,  DRV_nDB_ADD);
            process_check (wParam,  DRV_DB_ADD);
            process_check (wParam,  DRV_0_ADD);
            process_check (wParam,  DRV_SB_ADD);
            process_check (wParam,  DRV_ADL_ADD);
            process_check (wParam,  DRV_ANDS);
            process_check (wParam,  DRV_EORS);
            process_check (wParam,  DRV_ORS);
            process_check (wParam,  DRV_I_ADDC);
            process_check (wParam,  DRV_SRS);
            process_check (wParam,  DRV_SUMS);
            process_check (wParam,  DRV_DAA);
            process_check (wParam,  DRV_ADD_SB7);
            process_check (wParam,  DRV_ADD_SB06);
            process_check (wParam,  DRV_ADD_ADL);
            process_check (wParam,  DRV_DSA);
            process_check (wParam,  DRV_0_ADH0);
            process_check (wParam,  DRV_SB_DB);
            process_check (wParam,  DRV_SB_AC);
            process_check (wParam,  DRV_SB_ADH);
            process_check (wParam,  DRV_0_ADH17);
            process_check (wParam,  DRV_AC_SB);
            process_check (wParam,  DRV_AC_DB);

            process_check (wParam,  DRV_ADH_PCH);
            process_check (wParam,  DRV_PCH_PCH);
            process_check (wParam,  DRV_PCH_DB);
            process_check (wParam,  DRV_PCL_DB);
            process_check (wParam,  DRV_PCH_ADH);
            process_check (wParam,  DRV_PCL_PCL);
            process_check (wParam,  DRV_PCL_ADL);
            process_check (wParam,  DRV_ADL_PCL );
            process_check (wParam,  DRV_IPC );

            process_check (wParam,  DRV_DL_ADL );
            process_check (wParam,  DRV_DL_ADH );
            process_check (wParam,  DRV_DL_DB );

            process_check (wParam, LATCH_TRSYNC);
            process_check (wParam, LINE_PHI0);
            process_check (wParam, LINE_PHI1);
            process_check (wParam, LINE_PHI2);
            process_check (wParam, LINE_NMI);
            process_check (wParam, LINE_FROMNMI);
            process_check (wParam, LINE_IRQ);
            process_check (wParam, LINE_FROMIRQ);
            process_check (wParam, LINE_RDY);
            process_check (wParam, LATCH_BR0);
            process_check (wParam, LATCH_BR1);
            process_check (wParam, LINE_RES);
            process_check (wParam, LINE_FROMRES);
            process_check (wParam, LINE_SO);
            process_check (wParam, LINE_FROMSO);
            process_check (wParam, LATCH_SO0);
            process_check (wParam, LATCH_SO1);
            process_check (wParam, LATCH_SO2);

            for (i=0; i<129; i++) process_check (wParam, PLA_BASE+i);

            switch (LOWORD(wParam))
            {
                case STEP_BUTTON:
                    DebugNES->Step6502 (&DebugNES->cpu);
                    update_debugger (DebugNES);
                    DebugNES->cpu.PHI0 ^= 1;
                    return 0;
    
                case MISC_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "MISC");
                    update_debugger (DebugNES);
                    return 0;

                case TSTEP_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "TSTEP");
                    update_debugger (DebugNES);
                    return 0;

                case IR_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "IR");
                    update_debugger (DebugNES);
                    return 0;

                case PLA_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "PLA");
                    update_debugger (DebugNES);
                    return 0;

                case PREDECODE_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "PREDECODE");
                    update_debugger (DebugNES);
                    return 0;

                case RANDOM1_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "RANDOM1");
                    update_debugger (DebugNES);
                    return 0;

                case RANDOM2_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "RANDOM2");
                    update_debugger (DebugNES);
                    return 0;

                case ALU_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "ALU");
                    update_debugger (DebugNES);
                    return 0;

                case DATA_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "DATA");
                    update_debugger (DebugNES);
                    return 0;

                case REGS_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "REGS");
                    update_debugger (DebugNES);
                    return 0;

                case PC_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "PC");
                    update_debugger (DebugNES);
                    return 0;

                case ADDR_BUTTON:
                    DebugNES->Debug6502 (&DebugNES->cpu, "ADDR");
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
    bold_font ( CreateWindow ("static", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 55, 14, dlg, (HMENU)0, hInstance, NULL) );
}
static void label_long ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text )
{
    bold_font ( CreateWindow ("static", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 90, 14, dlg, (HMENU)0, hInstance, NULL) );
}
static HWND value ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text, int id )
{
    HWND hwnd = CreateWindow ("edit", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 16, 14, dlg, (HMENU)id, hInstance, NULL);
    set_font ( hwnd );
    return hwnd;
}
static HWND valueRead ( HINSTANCE hInstance, HWND dlg, int x, int y, char * text, int id )
{
    HWND hwnd = CreateWindow ("static", text, WS_CHILD | WS_VISIBLE | SS_LEFT, x, y, 75, 14, dlg, (HMENU)id, hInstance, NULL);
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
    int x, y, i;

    // Registers section
    label (hinst, dlg, 12, 8, "ADDR" );
    debugCtrl[VAL_ADDR] = valueRead (hinst, dlg, 44, 8, "1234", VAL_ADDR );

    y = 15;
    label (hinst, dlg, 12, y+=15, "X" );
    label (hinst, dlg, 12, y+=15, "Y" );
    label (hinst, dlg, 12, y+=15, "S" );
    label (hinst, dlg, 12, y+=15, "ABH" );
    label (hinst, dlg, 12, y+=15, "ABL" );
    y = 15;
    debugCtrl[VAL_X] = value (hinst, dlg, 25, y+=15, "12", VAL_X );
    debugCtrl[VAL_Y] = value (hinst, dlg, 25, y+=15, "34", VAL_Y );
    debugCtrl[VAL_S] = value (hinst, dlg, 25, y+=15, "56", VAL_S );
    debugCtrl[VAL_ABH] = value (hinst, dlg, 36, y+=15, "56", VAL_ABH );
    debugCtrl[VAL_ABL] = value (hinst, dlg, 36, y+=15, "56", VAL_ABL );

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

    y = 390;
    label (hinst, dlg, 410, y+=15, "PD" );
    label (hinst, dlg, 410, y+=15, "IR" );
    debugCtrl[VAL_MODE] = valueRead (hinst, dlg, 410, y+=15, "", VAL_MODE );
    y = 390;
    debugCtrl[VAL_PD] = value (hinst, dlg, 436, y+=15, "12", VAL_PD );
    debugCtrl[VAL_IR] = value (hinst, dlg, 436, y+=15, "12", VAL_IR );
    debugCtrl[VAL_DISA] = valueRead (hinst, dlg, 462, y, "", VAL_DISA );

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

    // Misc. logic lines and latches
    y = 308; x = 410;
    debugCtrl[LATCH_TRSYNC] = toggle (hinst, dlg, 410, y+=15, "TRSync", LATCH_TRSYNC );
    debugCtrl[LINE_T2] = toggle (hinst, dlg, x, y+=15, "T2", LINE_T2 );
    debugCtrl[LINE_T3] = toggle (hinst, dlg, x, y+=15, "T3", LINE_T3 );
    debugCtrl[LINE_T4] = toggle (hinst, dlg, x, y+=15, "T4", LINE_T4 );
    debugCtrl[LINE_T5] = toggle (hinst, dlg, x, y+=15, "T5", LINE_T5 );
    y = 5;
    debugCtrl[LINE_PHI0] = toggle (hinst, dlg, 410, y, "PHI0", LINE_PHI0 );
    debugCtrl[LINE_PHI1] = toggle (hinst, dlg, 410, y+=15, "PHI1", LINE_PHI1 );
    debugCtrl[LINE_PHI2] = toggle (hinst, dlg, 410, y+=15, "PHI2", LINE_PHI2 );
    y = 5;
    debugCtrl[LINE_NMI] = toggle (hinst, dlg, 480, y, "/NMI", LINE_NMI );
    debugCtrl[LINE_FROMNMI] = toggle (hinst, dlg, 480, y+=15, "NMI line", LINE_FROMNMI );
    y = 5;
    debugCtrl[LINE_IRQ] = toggle (hinst, dlg, 550, y, "/IRQ", LINE_IRQ );
    debugCtrl[LINE_FROMIRQ] = toggle (hinst, dlg, 550, y+=15, "IRQ line", LINE_FROMIRQ );
    y = 5;
    debugCtrl[LINE_RDY] = toggle (hinst, dlg, 620, y, "RDY", LINE_RDY );
    debugCtrl[LATCH_BR0] = toggle (hinst, dlg, 620, y+=15, "BRLatch0", LATCH_BR0 );
    debugCtrl[LATCH_BR1] = toggle (hinst, dlg, 620, y+=15, "BRLatch1", LATCH_BR1 );
    y = 5;
    debugCtrl[LINE_RES] = toggle (hinst, dlg, 690, y, "RES", LINE_RES );
    debugCtrl[LINE_FROMRES] = toggle (hinst, dlg, 690, y+=15, "RES line", LINE_FROMRES );
    y = 5;
    debugCtrl[LINE_SO] = toggle (hinst, dlg, 760, y, "SO", LINE_SO );
    debugCtrl[LINE_FROMSO] = toggle (hinst, dlg, 760, y+=15, "FromSO", LINE_FROMSO );
    y = 5;
    debugCtrl[LATCH_SO0] = toggle (hinst, dlg, 830, y, "SOLatch0", LATCH_SO0 );
    debugCtrl[LATCH_SO1] = toggle (hinst, dlg, 830, y+=15, "SOLatch1", LATCH_SO1 );
    debugCtrl[LATCH_SO2] = toggle (hinst, dlg, 830, y+=15, "SOLatch2", LATCH_SO2 );

    // Buttons
    set_font ( CreateWindow ("button", "Step", WS_CHILD | WS_VISIBLE, 880, 420, 80, 30, dlg, (HMENU)STEP_BUTTON, hinst, NULL) );

    set_font ( CreateWindow ("button", "REGS", WS_CHILD | WS_VISIBLE, 970, 320, 55, 30, dlg, (HMENU)REGS_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "PC", WS_CHILD | WS_VISIBLE, 1025, 320, 55, 30, dlg, (HMENU)PC_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "ADDR", WS_CHILD | WS_VISIBLE, 1080, 320, 55, 30, dlg, (HMENU)ADDR_BUTTON, hinst, NULL) );

    set_font ( CreateWindow ("button", "MISC", WS_CHILD | WS_VISIBLE, 970, 353, 55, 30, dlg, (HMENU)MISC_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "TSTEP", WS_CHILD | WS_VISIBLE, 1025, 353, 55, 30, dlg, (HMENU)TSTEP_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "IR", WS_CHILD | WS_VISIBLE, 1080, 353, 55, 30, dlg, (HMENU)IR_BUTTON, hinst, NULL) );

    set_font ( CreateWindow ("button", "PLA", WS_CHILD | WS_VISIBLE, 970, 385, 55, 30, dlg, (HMENU)PLA_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "PD", WS_CHILD | WS_VISIBLE, 1025, 385, 55, 30, dlg, (HMENU)PREDECODE_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "RAND1", WS_CHILD | WS_VISIBLE, 1080, 385, 55, 30, dlg, (HMENU)RANDOM1_BUTTON, hinst, NULL) );

    set_font ( CreateWindow ("button", "RAND2", WS_CHILD | WS_VISIBLE, 970, 420, 55, 30, dlg, (HMENU)RANDOM2_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "ALU", WS_CHILD | WS_VISIBLE, 1025, 420, 55, 30, dlg, (HMENU)ALU_BUTTON, hinst, NULL) );
    set_font ( CreateWindow ("button", "DATA", WS_CHILD | WS_VISIBLE, 1080, 420, 55, 30, dlg, (HMENU)DATA_BUTTON, hinst, NULL) );

    PlotDone = 1;
}

static void check ( int ctrl, int value )
{
    SendMessage (debugCtrl[ctrl], BM_SETCHECK, value ? BST_CHECKED : BST_UNCHECKED, 0);
}

static void setvalue8 ( int ctrl, unsigned char value )
{
    char text[256];
    sprintf ( text, "%02X", value );
    SendMessage (debugCtrl[ctrl],  WM_SETTEXT, (WPARAM)NULL, (LPARAM)text );
}

static void setvalue16 ( int ctrl, unsigned short value )
{
    char text[256];
    sprintf ( text, "%04X", value );
    SendMessage (debugCtrl[ctrl],  WM_SETTEXT, (WPARAM)NULL, (LPARAM)text );
}

static void update_debugger (ContextBoard *nes)
{
    Context6502 *cpu = &nes->cpu;
    int i;

    setvalue16 ( VAL_ADDR, packreg(cpu->ADDR, 16) );

    setvalue8 ( VAL_SB, packreg(cpu->SB, 8) );
    setvalue8 ( VAL_DB, packreg(cpu->DB, 8) );
    setvalue8 ( VAL_X, packreg(cpu->X, 8) );
    setvalue8 ( VAL_Y, packreg(cpu->Y, 8) );
    setvalue8 ( VAL_S, packreg(cpu->S, 8) );
    setvalue8 ( VAL_ABH, packreg(cpu->ABH, 8) );
    setvalue8 ( VAL_ABL, packreg(cpu->ABL, 8) );
    setvalue8 ( VAL_ADH, packreg(cpu->ADH, 8) );
    setvalue8 ( VAL_ADL, packreg(cpu->ADL, 8) );

    setvalue8 ( VAL_AI, packreg(cpu->AI, 8) );
    setvalue8 ( VAL_BI, packreg(cpu->BI, 8) );
    setvalue8 ( VAL_ADD, packreg(cpu->ADD, 8) );
    setvalue8 ( VAL_AC, packreg(cpu->AC, 8) );

    setvalue8 ( VAL_PCL, packreg(cpu->PCL, 8) );
    setvalue8 ( VAL_PCLS, packreg(cpu->PCLS, 8) );
    setvalue8 ( VAL_PCH, packreg(cpu->PCH, 8) );
    setvalue8 ( VAL_PCHS, packreg(cpu->PCHS, 8) );

    setvalue8 ( VAL_DL, packreg(cpu->DL, 8) );
    setvalue8 ( VAL_DOR, packreg(cpu->DOR, 8) );
    setvalue8 ( VAL_DATA, packreg(cpu->DATA, 8) );

    setvalue8 ( VAL_PD, packreg(cpu->PD, 8) );
    setvalue8 ( VAL_IR, packreg(cpu->IR, 8) );

    check ( DRV_ADH_ABH, cpu->DRIVEREG[DRIVE_ADH_ABH] );
    check ( DRV_ADL_ABL, cpu->DRIVEREG[DRIVE_ADL_ABL] );
    check ( DRV_0_ADL0, cpu->DRIVEREG[DRIVE_0_ADL0] );
    check ( DRV_0_ADL1, cpu->DRIVEREG[DRIVE_0_ADL1] );
    check ( DRV_0_ADL2, cpu->DRIVEREG[DRIVE_0_ADL2] );

    check ( DRV_Y_SB, cpu->DRIVEREG[DRIVE_Y_SB] );
    check ( DRV_X_SB, cpu->DRIVEREG[DRIVE_X_SB] );
    check ( DRV_SB_Y, cpu->DRIVEREG[DRIVE_SB_Y] );
    check ( DRV_SB_X, cpu->DRIVEREG[DRIVE_SB_X] );
    check ( DRV_S_SB, cpu->DRIVEREG[DRIVE_S_SB] );
    check ( DRV_S_ADL, cpu->DRIVEREG[DRIVE_S_ADL] );
    check ( DRV_SB_S, cpu->DRIVEREG[DRIVE_SB_S] );
    check ( DRV_S_S, cpu->DRIVEREG[DRIVE_S_S] );

    check ( DRV_nDB_ADD, cpu->DRIVEREG[DRIVE_NOTDB_ADD] );
    check ( DRV_DB_ADD, cpu->DRIVEREG[DRIVE_DB_ADD] );
    check ( DRV_0_ADD, cpu->DRIVEREG[DRIVE_0_ADD] );
    check ( DRV_SB_ADD, cpu->DRIVEREG[DRIVE_SB_ADD] );
    check ( DRV_ADL_ADD, cpu->DRIVEREG[DRIVE_ADL_ADD] );
    check ( DRV_ANDS, cpu->DRIVEREG[DRIVE_ANDS] );
    check ( DRV_EORS, cpu->DRIVEREG[DRIVE_EORS] );
    check ( DRV_ORS, cpu->DRIVEREG[DRIVE_ORS] );
    check ( DRV_I_ADDC, cpu->DRIVEREG[DRIVE_I_ADDC] );
    check ( DRV_SRS, cpu->DRIVEREG[DRIVE_SRS] );
    check ( DRV_SUMS, cpu->DRIVEREG[DRIVE_SUMS] );
    check ( DRV_DAA, cpu->DRIVEREG[DRIVE_DAA] );
    check ( DRV_ADD_SB7, cpu->DRIVEREG[DRIVE_ADD_SB7] );
    check ( DRV_ADD_SB06, cpu->DRIVEREG[DRIVE_ADD_SB06] );
    check ( DRV_ADD_ADL, cpu->DRIVEREG[DRIVE_ADD_ADL] );
    check ( DRV_DSA, cpu->DRIVEREG[DRIVE_DSA] );
    check ( DRV_0_ADH0, cpu->DRIVEREG[DRIVE_0_ADH0] );
    check ( DRV_SB_DB, cpu->DRIVEREG[DRIVE_SB_DB] );
    check ( DRV_SB_AC, cpu->DRIVEREG[DRIVE_SB_AC] );
    check ( DRV_SB_ADH, cpu->DRIVEREG[DRIVE_SB_ADH] );
    check ( DRV_0_ADH17, cpu->DRIVEREG[DRIVE_0_ADH17] );
    check ( DRV_AC_SB, cpu->DRIVEREG[DRIVE_AC_SB] );
    check ( DRV_AC_DB, cpu->DRIVEREG[DRIVE_AC_DB] );

    check ( DRV_ADH_PCH, cpu->DRIVEREG[DRIVE_ADH_PCH] );
    check ( DRV_PCH_PCH, cpu->DRIVEREG[DRIVE_PCH_PCH] );
    check ( DRV_PCH_DB, cpu->DRIVEREG[DRIVE_PCH_DB] );
    check ( DRV_PCL_DB, cpu->DRIVEREG[DRIVE_PCL_DB] );
    check ( DRV_PCH_ADH, cpu->DRIVEREG[DRIVE_PCH_ADH] );
    check ( DRV_PCL_PCL, cpu->DRIVEREG[DRIVE_PCL_PCL] );
    check ( DRV_PCL_ADL, cpu->DRIVEREG[DRIVE_PCL_ADL] );
    check ( DRV_ADL_PCL, cpu->DRIVEREG[DRIVE_ADL_PCL] );
    check ( DRV_IPC, cpu->DRIVEREG[DRIVE_IPC] );

    check ( DRV_DL_ADL, cpu->DRIVEREG[DRIVE_DL_ADL] );
    check ( DRV_DL_ADH, cpu->DRIVEREG[DRIVE_DL_ADH] );
    check ( DRV_DL_DB, cpu->DRIVEREG[DRIVE_DL_DB] );

    check ( LATCH_TRSYNC, cpu->TRSync );
    check ( LINE_PHI0, cpu->PHI0 );
    check ( LINE_PHI1, cpu->PHI1 );
    check ( LINE_PHI2, cpu->PHI2 );
    check ( LINE_NMI, cpu->NMI );
    check ( LINE_FROMNMI, cpu->FromNMI );
    check ( LINE_IRQ, cpu->IRQ );
    check ( LINE_FROMIRQ, cpu->FromIRQ );
    check ( LINE_RDY, cpu->RDY );
    check ( LATCH_BR0, cpu->BRLatch[0] );
    check ( LATCH_BR1, cpu->BRLatch[1] );
    check ( LINE_RES, cpu->RES );
    check ( LINE_FROMRES, cpu->FromRES );
    check ( LINE_SO, cpu->SO );
    check ( LINE_FROMSO, cpu->FromSO );
    check ( LATCH_SO0, cpu->SOLatch[0] );
    check ( LATCH_SO1, cpu->SOLatch[1] );
    check ( LATCH_SO2, cpu->SOLatch[2] );

    for (i=0; i<129; i++) check ( PLA_BASE+i, cpu->PLAOUT[i] );

    SendMessage (debugCtrl[VAL_DISA], WM_SETTEXT, (WPARAM)NULL, (LPARAM)QuickDisa(~packreg(cpu->IR, 8)) );
    if (cpu->PHI0 == 0) SendMessage (debugCtrl[VAL_MODE], WM_SETTEXT, (WPARAM)NULL, (LPARAM)"Write Mode" );
    if (cpu->PHI0 == 1) SendMessage (debugCtrl[VAL_MODE], WM_SETTEXT, (WPARAM)NULL, (LPARAM)"Read Mode" );
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
