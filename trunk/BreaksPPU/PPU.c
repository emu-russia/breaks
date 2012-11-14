// NES PPU clock-accurate emulator.
#include "PPU.h"
#include <stdio.h>

// Global quickies.

#define RES      (ppu->ctrl[PPU_CTRL_RES])
#define RC       (ppu->ctrl[PPU_CTRL_RC])
#define RESCL       (ppu->ctrl[PPU_CTRL_RESCL])
#define PCLK    (ppu->ctrl[PPU_CTRL_PCLK])
#define nPCLK    (ppu->ctrl[PPU_CTRL_nPCLK])

// ------------------------------------------------------------------------

// Basic logic
#define BIT(n)     ( (n) & 1 )
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

// ------------------------------------------------------------------------
// RENDER

// CLK is uses only inside render pipeline for chrominance phase generation.
// Other PPU components are clocked by double-rated pixel clock

// Reset -> Clock distribution -> Pixel clock -> R/W decoder -> Reg select -> H/V -> Palette RAS/CAS -> Color buffer -> Phase shifter -> Phase select -> Emphasis -> Level select -> DAC

static void PPU_RESET (ContextPPU *ppu)
{
    // Reset
    RES = NOT(ppu->pad[PPU_nRES]);
    RC = NOT(ppu->latch[PPU_FF_RESET]) & NOT(RES);
    ppu->latch[PPU_FF_RESET] = NOT(RC) & NOT(RESCL);
}

// Clock distribution
#define PPU_CLOCK(ppu)      ppu->ctrl[PPU_CTRL_nCLK] = NOT(ppu->pad[PPU_CLK])

// Pixel clock (CLK/4)
static void PPU_PIXEL_CLOCK (ContextPPU *ppu)
{
    if ( ppu->pad[PPU_CLK] ) {
        ppu->latch[PPU_FF_PCLK0] = NOT(PCLK) & NOT(RES);
        ppu->latch[PPU_FF_PCLK2] = NOT(ppu->latch[PPU_FF_PCLK1]);
    }
    if ( ppu->ctrl[PPU_CTRL_nCLK] ) {
        ppu->latch[PPU_FF_PCLK1] = NOT(ppu->latch[PPU_FF_PCLK0]);
        ppu->latch[PPU_FF_PCLK3] = NOT(ppu->latch[PPU_FF_PCLK2]);
    }
    PCLK = NOT(ppu->latch[PPU_FF_PCLK3]);
}

// H/V counters
static void PPU_HV (ContextPPU *ppu)
{
}

// ------------------------------------------------------------------------
// OAM evaluation, control registers, MUX

// Control registers -> OAM counters control -> Primary OAM counter -> Secondary OAM counter -> OAM evaluation -> OAM H-selector -> MUX

// ------------------------------------------------------------------------
// OAM controller

// OAM RAS/CAS -> OAM buffer

// ------------------------------------------------------------------------
// OAM FIFO

// H-inversion -> PPU buffer -> H-counters -> Attributes -> Shift registers -> OAM Priority

// ------------------------------------------------------------------------
// DATA READER

// Scroll setup -> PAR controls -> PAR counters -> V-inversion -> PAR -> Pattern readout -> BG color

// ------------------------------------------------------------------------

void PPUStep (ContextPPU *ppu)
{
    PPU_RESET (ppu);
    PPU_CLOCK (ppu);
    PPU_PIXEL_CLOCK (ppu);
    PPU_HV (ppu);
}

// Example emulation run-flow.
//

#if 1
#include <windows.h>

main ()
{
    DWORD cycles, old;
    ContextPPU ppu;
    memset (&ppu, 0, sizeof(ppu));
    ppu.pad[PPU_nRES] = 1;
    
    cycles = 0;
    old = GetTickCount ();
    while (1) {
        if ( (GetTickCount () - old) >= 1000 ) break;
        PPUStep (&ppu);
        ppu.pad[PPU_CLK] ^= 1;
        cycles++;
    }
    printf ("Executed %.4fM/44M cycles\n", (float)cycles/1000000.0f );
}

#endif