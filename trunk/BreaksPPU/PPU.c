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
    nPCLK = NOT(PCLK);
}

// H/V counters
static void PPU_HV (ContextPPU *ppu)
{
    int n, in;

    #define HIN(n) (ppu->reg[PPU_REG_HIN][n])
    #define HOUT(n) (ppu->reg[PPU_REG_HOUT][n])
    #define VIN(n) (ppu->reg[PPU_REG_VIN][n])
    #define VOUT(n) (ppu->reg[PPU_REG_VOUT][n])
    #define H(n) (ppu->bus[PPU_BUS_H][n])
    #define nH(n) NOT(ppu->bus[PPU_BUS_H][n])
    #define V(n) (ppu->bus[PPU_BUS_V][n])
    #define nV(n) NOT(ppu->bus[PPU_BUS_V][n])

    ppu->debug[PPU_DEBUG_H] = ppu->debug[PPU_DEBUG_V] = 0;

    // V-counter input
    ppu->ctrl[PPU_CTRL_VIN] = NOT (H(0) | H(1) | nH(2) | H(3) | nH(4) | H(5) | nH(6) | H(7) | nH(8));

    // clear H/V counters

    // propagate counters
    for (n=0, in=1; n<9; n++) {   // H-counter
        if (PCLK) {
            HOUT(n) = NOT(HIN(n)) & NOT(ppu->ctrl[PPU_CTRL_HC]);
        }
        if (nPCLK) {
            if (in) HIN(n) = HOUT(n) & NOT(RES);
            else HIN(n) = NOT(HOUT(n));
        }
        // H carry
        if ( n == 4 ) in = NOT ( NOT(HOUT(0)) | NOT(HOUT(1)) | NOT(HOUT(2)) | NOT(HOUT(3)) | NOT(HOUT(4)) );
        else in = HOUT(n) & in;
        H(n) = HOUT(n) & NOT(RES);
        if (H(n)) ppu->debug[PPU_DEBUG_H] |= 1 << n;
    }
    for (n=0, in=ppu->ctrl[PPU_CTRL_VIN]; n<9; n++) {   // V-counter
        if (PCLK) {
            VOUT(n) = NOT(VIN(n)) & NOT(ppu->ctrl[PPU_CTRL_VC]);
        }
        if (nPCLK) {
            if (in) VIN(n) = VOUT(n) & NOT(RES);
            else VIN(n) = NOT(VOUT(n));
        }
        // V carry
        if ( n == 4 ) in = NOT ( NOT(VOUT(0)) | NOT(VOUT(1)) | NOT(VOUT(2)) | NOT(VOUT(3)) | NOT(VOUT(4)) | NOT(ppu->ctrl[PPU_CTRL_VIN]) );
        else in = VOUT(n) & in;
        V(n) = VOUT(n) & NOT(RES);
        if (V(n)) ppu->debug[PPU_DEBUG_V] |= 1 << n;
    }

    // H select
    ppu->bus[PPU_BUS_HSEL][0] = NOT( nH(0) | nH(1) | nH(2) | H(3) | nH(4) | H(5) | H(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][1] = NOT( H(0) | H(1) | H(2) | H(3) | H(4) | H(5) | H(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][2] = NOT( nH(0) | H(1) | H(2) | H(3) | H(4) | H(5) | nH(6) | H(7) | H(8) );
    ppu->bus[PPU_BUS_HSEL][3] = NOT( H(3) | H(4) | H(5) | H(6) | H(7) );
    ppu->bus[PPU_BUS_HSEL][4] = NOT( H(8) );
    ppu->bus[PPU_BUS_HSEL][5] = NOT( H(2) | H(3) | nH(4) | H(5) | nH(6) | H(7) | nH(8) );

    ppu->bus[PPU_BUS_HSEL][6] = NOT( nH(0) | nH(1) | nH(2) | nH(3) | nH(4) | nH(5) | H(6) | H(7) | H(8) );
    ppu->bus[PPU_BUS_HSEL][7] = NOT( nH(0) | nH(1) | nH(2) | nH(3) | nH(4) | nH(5) | nH(6) | nH(7) );
    ppu->bus[PPU_BUS_HSEL][8] = NOT( H(6) | H(7) | H(8) );

    ppu->bus[PPU_BUS_HSEL][9] = NOT( H(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][10] = NOT( H(8) );
    ppu->bus[PPU_BUS_HSEL][11] = NOT( H(1) | H(2) );
    ppu->bus[PPU_BUS_HSEL][12] = NOT( nH(1) | nH(2) );
    ppu->bus[PPU_BUS_HSEL][13] = NOT( H(1) | nH(2) );

    ppu->bus[PPU_BUS_HSEL][14] = NOT( H(4) | H(5) | nH(6) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][15] = NOT( H(8) );
    ppu->bus[PPU_BUS_HSEL][16] = NOT( nH(1) | H(2) );
    ppu->bus[PPU_BUS_HSEL][17] = NOT( H(0) | nH(1) | nH(2) | nH(3) | H(4) | H(5) | H(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][18] = NOT( H(0) | H(1) | H(2) | nH(3) | H(4) | H(5) | nH(6) | H(7) | nH(8) );

    ppu->bus[PPU_BUS_HSEL][19] = NOT( nH(0) | nH(1) | nH(2) | H(3) | nH(4) | H(5) | H(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][20] = NOT( H(0) | H(1) | H(2) | H(3) | nH(4) | nH(5) | H(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][21] = NOT( nH(0) | nH(1) | H(2) | H(3) | H(4) | H(5) | nH(6) | H(7) | nH(8) );
    ppu->bus[PPU_BUS_HSEL][22] = NOT( H(0) | H(1) | nH(2) | H(3) | nH(4) | nH(5) | H(6) | H(7) | nH(8) );

    // V select
    ppu->bus[PPU_BUS_VSEL][0] = NOT( nV(0) | nV(1) | nV(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );
    ppu->bus[PPU_BUS_VSEL][1] = NOT( V(0) | V(1) | nV(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );
    ppu->bus[PPU_BUS_VSEL][2] = NOT( nV(0) | V(1) | nV(2) | V(3) | V(4) | V(5) | V(6) | V(7) | nV(8) );

    ppu->bus[PPU_BUS_VSEL][3] = NOT( nV(0) | V(1) | V(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );
    ppu->bus[PPU_BUS_VSEL][4] = NOT( nV(0) | V(1) | V(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );
    ppu->bus[PPU_BUS_VSEL][5] = NOT( V(0) | V(1) | V(2) | V(3) | V(4) | V(5) | V(6) | V(7) | V(8) );
    ppu->bus[PPU_BUS_VSEL][6] = NOT( V(0) | V(1) | V(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );
    ppu->bus[PPU_BUS_VSEL][7] = NOT( nV(0) | V(1) | nV(2) | V(3) | V(4) | V(5) | V(6) | V(7) | nV(8) );

    ppu->bus[PPU_BUS_VSEL][8] = NOT( nV(0) | V(1) | nV(2) | V(3) | V(4) | V(5) | V(6) | V(7) | nV(8) );

    // H/V random logic

    //printf ( "%i %i H=%i V=%i\n", ppu->pad[PPU_CLK], PCLK, ppu->debug[PPU_DEBUG_H], ppu->debug[PPU_DEBUG_V] );
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