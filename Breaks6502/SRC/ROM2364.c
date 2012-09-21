// 2364 8 KB ROM simulator.
#include "ROM2364.h"

// Load ROM with specific data.
static void Load2364 (Context2364 * rom )
{
    memset ( rom->ROM, 0, sizeof(rom->ROM) );
}

void Step2364 ( Context2364 * rom )
{
    unsigned char data = 0;
    unsigned short addr = 0;
    int i;

    if (!rom->init) {
        Load2364 (rom);
        rom->init = 1;
    }

    if (rom->CS == 0) {  // Read data when chip selected (active low)
        for (i=0; i<13; i++) addr |= (rom->ADDR[i] << i);
        data = rom->ROM[addr & 0x1fff];
    }

    for (i=0; i<8; i++) {
        rom->DATA[i] = (data >> i) & 1;
    }
}
