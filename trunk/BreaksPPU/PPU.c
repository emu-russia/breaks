// NES PPU clock-accurate emulator.
#include "PPU.h"
#include <stdio.h>

// Global quickies.

#define RES      (ppu->ctrl[PPU_CTRL_RES])
#define RC       (ppu->ctrl[PPU_CTRL_RC])
#define RESCL    (ppu->ctrl[PPU_CTRL_RESCL])
#define PCLK     (ppu->ctrl[PPU_CTRL_PCLK])
#define nPCLK    (ppu->ctrl[PPU_CTRL_nPCLK])

// Flip/flop
#define FF(ff,out,r,s)  \
    out = NOT(ff) & NOT(s); \
    ff = out & NOT(r); 

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

#define HIN(n) (ppu->reg[PPU_REG_HIN][n])
#define HOUT(n) (ppu->reg[PPU_REG_HOUT][n])
#define VIN(n) (ppu->reg[PPU_REG_VIN][n])
#define VOUT(n) (ppu->reg[PPU_REG_VOUT][n])
#define H(n) (ppu->bus[PPU_BUS_H][n])
#define nH(n) NOT(ppu->bus[PPU_BUS_H][n])
#define V(n) (ppu->bus[PPU_BUS_V][n])
#define nV(n) NOT(ppu->bus[PPU_BUS_V][n])
#define HSEL(n) (ppu->bus[PPU_BUS_HSEL][n])
#define VSEL(n) (ppu->bus[PPU_BUS_VSEL][n])
#define HRIN(n) (ppu->reg[PPU_REG_HRIN][n])
#define HROUT(n) (ppu->reg[PPU_REG_HROUT][n])
#define VRIN(n) (ppu->reg[PPU_REG_VRIN][n])
#define VROUT(n) (ppu->reg[PPU_REG_VROUT][n])
#define HR(n) (ppu->reg[PPU_REG_HR][n])
#define VR(n) (ppu->reg[PPU_REG_VR][n])

// print asserted H/V logic outputs.
static void dump_HV (ContextPPU *ppu)
{
    int n;
    if ( ppu->debug[PPU_DEBUG_V] > 0 ) exit (0);
    printf ( "PCLK:%i H:%i ", PCLK, ppu->debug[PPU_DEBUG_H] );

    if ( ppu->ctrl[PPU_CTRL_SEV] ) printf ( " S/EV" );
    if ( ppu->ctrl[PPU_CTRL_EEV] ) printf ( " E/EV" );
    if ( ppu->ctrl[PPU_CTRL_CLIP_O] ) printf ( " CLIP_O" );
    if ( ppu->ctrl[PPU_CTRL_CLIP_B] ) printf ( " CLIP_B" );
    if ( ppu->ctrl[PPU_CTRL_ZHPOS] ) printf ( " 0/HPOS" );
    if ( ppu->ctrl[PPU_CTRL_EVAL] ) printf ( " EVAL" );
    if ( ppu->ctrl[PPU_CTRL_IOAM2] ) printf ( " I/OAM2" );
    if ( ppu->ctrl[PPU_CTRL_FNT] ) printf ( " F/NT" );
    if ( ppu->ctrl[PPU_CTRL_FAT] ) printf ( " F/AT" );
    if ( ppu->ctrl[PPU_CTRL_PARO] ) printf ( " PAR/O" );
    if ( ppu->ctrl[PPU_CTRL_nVIS] ) printf ( " /VIS" );
    if ( ppu->ctrl[PPU_CTRL_FTA] ) printf ( " F/TA" );
    if ( ppu->ctrl[PPU_CTRL_FTB] ) printf ( " F/TB" );
    if ( ppu->ctrl[PPU_CTRL_FDUMMY] ) printf ( " F/-" );
    if ( ppu->ctrl[PPU_CTRL_BLNK] ) printf ( " BLNK" );
    if ( ppu->ctrl[PPU_CTRL_RESCL] ) printf ( " RESCL" );
    if ( ppu->ctrl[PPU_CTRL_PICTURE] ) printf ( " PICTURE" );
    if ( ppu->ctrl[PPU_CTRL_BURST] ) printf ( " BURST" );
    if ( ppu->ctrl[PPU_CTRL_SYNC] ) printf ( " SYNC" );
    if ( ppu->ctrl[PPU_CTRL_nINT] ) printf ( " /INT" );

    printf ( "\n" );
}

/*
    H/V logic input:
    PPU control register bits: OBCLIP, BGCLIP, BLACK, VBL
    /R2 and /DBE bus enablers (for DB7)

    H/V logic output:
    to render: SYNC, BURST, PICTURE
    drivers: CLIP_O, CLIP_B, 0/HPOS, EVAL, S/EV, E/EV, I/OAM2, PAR/O, /VIS,
             F/NT, F/AT, F/TA, F/TB, F/DUMMY,
             SC/CNT, BLNK, RESCL
    /INT (vblank out)
    connected to DB7 (for $2002.7 output).
*/

// H/V counters
static void PPU_HV (ContextPPU *ppu)
{
    int n, in;
    int ff, vb, blnk, porch;

    ppu->debug[PPU_DEBUG_H] = ppu->debug[PPU_DEBUG_V] = 0;

    // Early logic
    FF(VR(3),ff,VRIN(6),VRIN(5));     // Not vblank (lines 261...240)
    vb = NOT(ff);
    FF(VR(4),ff,VRIN(7),VRIN(6));      // Not picture (lines 240...0)
    blnk = ppu->ctrl[PPU_CTRL_BLNK] = ff | ppu->ctrl[PPU_CTRL_BLACK];

    // V-counter input
    ppu->ctrl[PPU_CTRL_VIN] = NOT (H(0) | H(1) | nH(2) | H(3) | nH(4) | H(5) | nH(6) | H(7) | nH(8));       // 340

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
    HSEL(0) = NOT( nH(0) | nH(1) | nH(2) | H(3) | nH(4) | H(5) | H(6) | H(7) | nH(8) );       // 279, front porch end
    HSEL(1) = NOT( H(0) | H(1) | H(2) | H(3) | H(4) | H(5) | H(6) | H(7) | nH(8) );           // 256, front porch start
    HSEL(2) = NOT( nH(0) | H(1) | H(2) | H(3) | H(4) | H(5) | nH(6) | H(7) | H(8) | blnk );     // 65, Start OAM evaluation
    HSEL(3) = NOT( H(3) | H(4) | H(5) | H(6) | H(7));       // 0-7, Object/Background clipping
    HSEL(4) = NOT( H(8) | vb );             // 0-255, Object/Background clipping
    HSEL(5) = NOT( H(2) | H(3) | nH(4) | H(5) | nH(6) | H(7) | nH(8) );     //  336-339, OAM FIFO clear H.position

    HSEL(6) = NOT( nH(0) | nH(1) | nH(2) | nH(3) | nH(4) | nH(5) | H(6) | H(7) | H(8) );    // 63, OAM evaluation
    HSEL(7) = NOT( nH(0) | nH(1) | nH(2) | nH(3) | nH(4) | nH(5) | nH(6) | nH(7) );     // 255, End OAM evaluation
    HSEL(8) = NOT( H(6) | H(7) | H(8) );        // 0-63, Clear secondary OAM

    HSEL(9) = NOT( H(6) | H(7) | nH(8) | blnk);     // 256-319, OAM pattern fetch
    HSEL(10) = NOT( H(8) | vb | blnk);      // 0-255, Visible scanline part
    HSEL(11) = NOT( H(1) | H(2) | blnk);        // 0/1, Name table fetch
    HSEL(12) = NOT( nH(1) | nH(2) );        // 6/7, Pattern fetch second byte
    HSEL(13) = NOT( H(1) | nH(2) );         // 4/5, Pattern fetch first byte

    HSEL(14) = NOT( H(4) | H(5) | nH(6) | nH(8) | blnk);        // 336-340 weird two name table reads
    HSEL(15) = NOT( H(8) | blnk);
    HSEL(16) = NOT( nH(1) | H(2) );         // 2/3, Attribute table fetch
    HSEL(17) = NOT( H(0) | nH(1) | nH(2) | nH(3) | H(4) | H(5) | H(6) | H(7) | nH(8) );     // 270
    HSEL(18) = NOT( H(0) | H(1) | H(2) | nH(3) | H(4) | H(5) | nH(6) | H(7) | nH(8) );      // 328

    HSEL(19) = NOT( nH(0) | nH(1) | nH(2) | H(3) | nH(4) | H(5) | H(6) | H(7) | nH(8) );    // 279
    HSEL(20) = NOT( H(0) | H(1) | H(2) | H(3) | nH(4) | nH(5) | H(6) | H(7) | nH(8) );      // 304
    HSEL(21) = NOT( nH(0) | nH(1) | H(2) | H(3) | H(4) | H(5) | nH(6) | H(7) | nH(8) );     // 323
    HSEL(22) = NOT( H(0) | H(1) | nH(2) | H(3) | nH(4) | nH(5) | H(6) | H(7) | nH(8) );     // 308

    // V select
    VSEL(0) = NOT( nV(0) | nV(1) | nV(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );      // 247
    VSEL(1) = NOT( V(0) | V(1) | nV(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );        // 244
    VSEL(2) = NOT( nV(0) | V(1) | nV(2) | V(3) | V(4) | V(5) | V(6) | V(7) | nV(8) );   // 261
    
    VSEL(3) = NOT( nV(0) | V(1) | V(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );        // 241
    VSEL(4) = NOT( nV(0) | V(1) | V(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );        // 241
    VSEL(5) = NOT( V(0) | V(1) | V(2) | V(3) | V(4) | V(5) | V(6) | V(7) | V(8) );      // 0
    VSEL(6) = NOT( V(0) | V(1) | V(2) | V(3) | nV(4) | nV(5) | nV(6) | nV(7) );         // 240
    VSEL(7) = NOT( nV(0) | V(1) | nV(2) | V(3) | V(4) | V(5) | V(6) | V(7) | nV(8) );   // 261

    VSEL(8) = NOT( nV(0) | V(1) | nV(2) | V(3) | V(4) | V(5) | V(6) | V(7) | nV(8) );   // 261

    // H/V random logic
    if (nPCLK) {    // Load input latches from H/V select
        for (n=0; n<23; n++) HRIN(n) = HSEL(n);
        for (n=4; n<8; n++) VRIN(n) = VSEL(n);
    }
    if (PCLK) {     // Check conditions and put result in output latches, alter flip/flops
        HROUT(2) = NOT(HRIN(2));            // S/EV
        HROUT(3) = NOR ( HRIN(3), NOT(HRIN(4)) );       // clipping appear only on left 8 pixels of visible frame
        HROUT(5) = NOT(HRIN(5));        // 0/HPOS
        HROUT(6) = NOT ( HRIN(5) | HRIN(6) | HRIN(7) );     // EVAL
        HROUT(7) = NOT (HRIN(7));       // E/EV
        HROUT(8) = NOT (HRIN(8));       // I/OAM2
        HROUT(9) = NOT (HRIN(9));       // PAR/O
        HROUT(10) = NOT (HRIN(10));     // nVIS
        HROUT(11) = NOT (HRIN(11));     // F/NT
        HROUT(12) = NOT (HRIN(12));     // F/TB
        HROUT(13) = NOT (HRIN(13));     // F/TA
        HROUT(14) = NOR (HRIN(14), HRIN(15));   // dummy

        VROUT(8) = NOT(VRIN(8));
    }
    // H/V logic outputs, based on output latch values, flip/flops and PPU control bits.
    FF (HR(0),porch,HRIN(0),HRIN(1));       // after 256 visible pixel there appear "front porch"
    ppu->ctrl[PPU_CTRL_SEV] = NOT(HROUT(2));
    ppu->ctrl[PPU_CTRL_CLIP_O] = NOT(HROUT(3)) & NOT(ppu->ctrl[PPU_CTRL_OBCLIP]);
    ppu->ctrl[PPU_CTRL_CLIP_B] = NOT(HROUT(3)) & NOT(ppu->ctrl[PPU_CTRL_BGCLIP]);
    ppu->ctrl[PPU_CTRL_ZHPOS] = NOT(HROUT(5));
    ppu->ctrl[PPU_CTRL_EVAL] = NOT(HROUT(6));
    ppu->ctrl[PPU_CTRL_EEV] = NOT(HROUT(7));
    ppu->ctrl[PPU_CTRL_IOAM2] = NOT(HROUT(8));
    ppu->ctrl[PPU_CTRL_PARO] = NOT(HROUT(9));
    ppu->ctrl[PPU_CTRL_nVIS] = NOT(HROUT(10));
    ppu->ctrl[PPU_CTRL_FNT] = NOT(HROUT(11));
    ppu->ctrl[PPU_CTRL_FTB] = NOR(HROUT(12), HROUT(14));
    ppu->ctrl[PPU_CTRL_FTA] = NOR(HROUT(13), HROUT(14));
    ppu->ctrl[PPU_CTRL_FDUMMY] = NOT(HROUT(14));
    ppu->ctrl[PPU_CTRL_FAT] = NOR(  NOR (HRIN(14), HRIN(15)), NOT(HRIN(16)) );
    ppu->ctrl[PPU_CTRL_RESCL] = NOT(VROUT(8));

    dump_HV (ppu);
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