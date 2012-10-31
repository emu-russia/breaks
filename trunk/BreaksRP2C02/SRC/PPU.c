// PPU controls.
#include "PPU.h"

unsigned long packreg ( char *reg, int bits )
{
    unsigned long val = 0, i;
    for (i=0; i<bits; i++) {
        if (reg[i]) val |= (1 << i);
    }
    return val;
} 

void unpackreg (char *reg, unsigned char val, int bits)
{
    int i;
    for (i=0; i<bits; i++) {
        reg[i] = (val >> i) & 1;
    }
}

// Basic logic
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

__declspec( dllexport ) void Step2C02 ( Context2C02 * ppu )
{
}

__declspec( dllexport ) void Debug2C02 ( Context2C02 * ppu, char *cmd )
{
}
