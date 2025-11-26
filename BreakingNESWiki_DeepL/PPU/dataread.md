# Data Reader

> [!WARNING]  
> This section of the wiki is currently undergoing refactoring due to an incorrect interpretation of the PAR (Picture Address Register) circuit layout. What was previously called "PatGen" is actually PAR, 
> and what was previously called PAR is actually an address multiplexer not shown in the patent (which we decided to simply call PPU Address Mux, or PAMUX).
> Furthermore, "PAR Counters" are now called "Tile Counters" because they have nothing in common with PAR.
> We also plan to provide more understandable and appropriate names for some signals (but only after the wiki refactoring).
> Eventually, once all the edits have been proofread and we've verified there are no renaming errors, this label will also be removed.

The PPU patent refers to this circuit as the `Still Picture Generator`.

The circuitry takes up almost a quarter of the PPU area and is located in the lower right corner of the chip:

![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/ppu_locator_dataread.jpg)

This circuit deals with sampling a row of 8 pixels, based on the scroll registers which set the position of the tile in the name table and the fine offset of the starting point within the tile.
The results (the current pixel of the tile) are sent to the multiplexer, to mix with the current pixel of the sprite.

The circuit also deals with getting sprite patterns and their V inversion (the H inversion circuit is in [OAM FIFO](fifo.md)).

Due to the large size, it will be difficult to show the entire diagram, so naturally we will saw it into its component parts.

Below is shown what circuits the Data Reader consists of, in order to understand where to look for the sawn pieces of circuits:

![ppu_datareader_sections](/BreakingNESWiki/imgstore/ppu/ppu_datareader_sections.png)

There was something in this section historically, but then it was split up into sections. The only thing left is the circuit for the generation of the tile address.

![DataReader_All](/BreakingNESWiki/imgstore/ppu/DataReader_All.png)

## The Rest

All parts of the schematic are located in the corresponding sections:

- [Picture Address Register (PAR) + V.INV](par.md)
- [Scrolling Registers](scroll_regs.md)
- [Tile Counters](tilecnt.md)
- [PPU Address Mux](pamux.md)
- [Background Color](bgcol.md)