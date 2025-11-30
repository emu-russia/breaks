# Data Reader

The PPU patent refers to this circuit as the `Still Picture Generator`.

The circuitry takes up almost a quarter of the PPU area and is located in the lower right corner of the chip:

![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/ppu_locator_dataread.jpg)

This circuit deals with sampling a row of 8 pixels, based on the scroll registers which set the position of the tile in the name table and the fine offset of the starting point within the tile.
The results (the current pixel of the tile) are sent to the multiplexer, to mix with the current pixel of the sprite.

The circuit also deals with getting sprite patterns and their V inversion (the H inversion circuit is in [Obj FIFO](fifo.md)).

Due to the large size, it will be difficult to show the entire diagram, so naturally we will saw it into its component parts.

Below is shown what circuits the Data Reader consists of, in order to understand where to look for the sawn pieces of circuits:

![ppu_datareader_sections](/BreakingNESWiki/imgstore/ppu/ppu_datareader_sections.png)

![DataReader_All](/BreakingNESWiki/imgstore/ppu/DataReader_All.png)

## The Rest

All parts of the schematic are located in the corresponding sections:

- [Picture Address Register (PAR) + V.INV](par.md)
- [Scroll Registers](scroll_regs.md)
- [Tile Counters](tilecnt.md)
- [PPU Address Mux](pamux.md)
- [Background Color](bgcol.md)