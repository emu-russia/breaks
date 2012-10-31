// Ricoh 2C02 PPU simulator.

typedef struct Context2C02 {

    int     DEBUG;          // do some debug output.

    // I/O pinout.
    char    CLK;
    float   VID;

    // --------------------------------------------------- Clocks
    char    _CLK;           // /CLK
    char    PCLK, _PCLK;    // pixel clock (PCLK and /PCLK)

    // --------------------------------------------------- Video output

    // --------------------------------------------------- H/V

    // --------------------------------------------------- H/V logic

    // --------------------------------------------------- Palette

    int     REGSEL[12];     // register select PLA result

    // --------------------------------------------------- OAM stuff
    char    OAMRAM[2112];   // OAM DRAM latches
    char    OAM[9];         // OAM index
    char    OAM_CAS[9];
    char    OAM_RAS[32];
    char    OBOut[8], OBIn[8];  // OAM buffer latches
    char    OAM_DIV8[4];        // divider by 8 latches
    char    OB[8], OB1[8];      // OAM buffer outputs
} Context2C02;

void Step2C02 ( Context2C02 * ppu );
void Debug2C02 ( Context2C02 * ppu, char *cmd );
