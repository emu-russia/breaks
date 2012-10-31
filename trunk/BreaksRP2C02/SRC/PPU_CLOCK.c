// Pixel clock generation.
#include "PPU.h"

void SUB_CLK (Context2C02 *ppu)
{
    ppu->CLK = BIT(ppu->CLK);
    ppu->_CLK = NOT(ppu->CLK);
}

void PIXEL_CLK (Context2C02 *ppu)
{
    char old = ppu->PCLK;

    if ( ppu->CLK ) {
        ppu->PCLKIn[0] = BIT(ppu->PCLKOut[1]) & NOT(ppu->RES);
        ppu->PCLKIn[1] = NOT(ppu->PCLKOut[0]);
    }
    else {
        ppu->PCLKOut[0] = NOT(ppu->PCLKIn[0]);
        ppu->PCLKOut[1] = NOT(ppu->PCLKIn[1]);
    }

    ppu->PCLK = NOT(ppu->PCLKOut[1]);
    ppu->_PCLK = BIT(ppu->PCLKOut[1]);
    if (old == 0 && ppu->PCLK != old) ppu->pixel++;

    // dump counter
    if (ppu->DEBUG) {
        printf ( "Pixel clock: %i%i%i%i, PCLK=%i, pixel: %i \n", 
                 ppu->PCLKIn[0], ppu->PCLKIn[1], ppu->PCLKOut[0], ppu->PCLKOut[1], ppu->PCLK, ppu->pixel );
    }
}