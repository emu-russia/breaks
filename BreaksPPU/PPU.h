
// Pads.
enum {
    PPU_CLK,        // clock input
    PPU_nRES,       // /RES
    PPU_nINT,       // /INT (vblank interrupt)
    PPU_EXT,        // external bus
    PPU_nDBE,       // /DBE
    PPU_RS,         // register select bus
    PPU_D,          // register data bus
    PPU_RW,         // register data bus direction
    PPU_ALE,        // address latch
    PPU_AD,         // address/data bus to external PPU memory
    PPU_nRD,        // /RD
    PPU_nWR,        // /WR
};

// ------------------------------------------------------------------------
// Control lines

enum {
    PPU_CTRL_RES,           // inverted /RES
    PPU_CTRL_RC,            // register clear
    PPU_CTRL_nCLK,          // /CLK
    PPU_CTRL_PCLK, PPU_CTRL_nPCLK,  // pixel clock phases
            // H/V counters
    PPU_CTRL_VIN,           // V-counter input
    PPU_CTRL_HC,            // H-counter clear
    PPU_CTRL_VC,            // V-counter clear
            // H/V logic
    PPU_CTRL_CLIP_O, PPU_CTRL_CLIP_B,   // clip objects/background
    PPU_CTRL_ZHPOS,         // 0/HPOS, reset H.position counters
    PPU_CTRL_EVAL,          // sprite evaluation in progress
    PPU_CTRL_PARO,          // fetch sprite patterns PAR/O
    PPU_CTRL_nVIS,          // visible scanline part /VIS
    PPU_CTRL_BLNK,          // picture not seen (vblank) or disabled by control regs
    PPU_CTRL_RESCL,         // clear reset flip/flop
    PPU_CTRL_SEV, PPU_CTRL_EEV,     // start/end OAM evaluation S/EV, E/EV
    PPU_CTRL_IOAM2,         // init secondary OAM I/OAM2
    PPU_CTRL_FNT, PPU_CTRL_FAT, PPU_CTRL_FTA, PPU_CTRL_FTB, PPU_CTRL_FDUMMY,    // memory fetch orders
    PPU_CTRL_PICTURE, PPU_CTRL_BURST, PPU_CTRL_SYNC,      // videout controls
    PPU_CTRL_nINT,          // /INT
        // control registers output
    PPU_CTRL_OBCLIP, PPU_CTRL_BGCLIP, PPU_CTRL_VBL,         
    PPU_CTRL_nTR, PPU_CTRL_nTG, PPU_CTRL_nTB, PPU_CTRL_BLACK, PPU_CTRL_BW,

    PPU_CTRL_MAX,
};

// ------------------------------------------------------------------------
// Individual static and dynamic latches (flip/flops)

enum {
    PPU_FF_RESET,           // reset flip/flop
    PPU_FF_PCLK0, PPU_FF_PCLK1, PPU_FF_PCLK2, PPU_FF_PCLK3, // pixel clock div/4 latches
    PPU_FF_HC, PPU_FF_VC,     // H/V-counter clear

    PPU_FF_MAX,
};

// ------------------------------------------------------------------------
// Registers

enum {
    PPU_REG_HIN, PPU_REG_HOUT,          // H-counter
    PPU_REG_VIN, PPU_REG_VOUT,          // V-counter
    PPU_REG_HRIN,                       // H-select input latches
    PPU_REG_HROUT,                      // H-select output latches
    PPU_REG_VRIN,                       // V-select input latches
    PPU_REG_VROUT,                      // V-select output latches
    PPU_REG_HR,                         // H-select flip/flops
    PPU_REG_VR,                         // V-select flip/flops

    PPU_REG_MAX,
};

// ------------------------------------------------------------------------
// Buses

enum {
    PPU_BUS_DB,             // internal data bus
    PPU_BUS_H, PPU_BUS_V,       // H/V counter outputs
    PPU_BUS_HSEL,PPU_BUS_VSEL,  // H/V select
    PPU_BUS_PAL,            // palette index
    PPU_BUS_OAM,            // OAM index
    PPU_BUS_PD,             // PPU data

    PPU_BUS_MAX,
};

// ------------------------------------------------------------------------
// Memory offsets

enum {
    PPU_MEM_OAM = 0,
    PPU_MEM_TEMP = 256,
    PPU_PALETTE = 288,
};    

// ------------------------------------------------------------------------
// Debug

enum {
    PPU_DEBUG_H, PPU_DEBUG_V,
    PPU_DEBUG_PIXCOUNT,

    PPU_DEBUG_MAX,
};

// ------------------------------------------------------------------------
// Context.

typedef struct ContextPPU
{
    float    vid;               // video output (composite video, normalized to 1.0)
    unsigned long pad[12];      // I/O pads and external buses
    char    latch[PPU_FF_MAX];       // individual latches
    int     ctrl[PPU_CTRL_MAX];      // control lines
    char    reg[PPU_REG_MAX][32];  // registers
    unsigned char mem[256+32+64];    // primary OAM, secondary OAM, palette
    unsigned long bus[PPU_BUS_MAX][32];  // internal buses
    int     debug[PPU_DEBUG_MAX];    // debug variables
} ContextPPU;

// Emulate single PPU clock.
void PPUStep (ContextPPU *ppu);
