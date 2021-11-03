# Data Reader

The circuitry takes up almost a quarter of the PPU area and is located in the lower right corner of the chip:

![DATAREAD_preview](/BreakingNESWiki/imgstore/DATAREAD_preview.jpg)

This circuit deals with sampling a row of 8 pixels, based on the scroll registers which set the position of the tile in the name table and the fine offset of the starting point within the tile.
The results (the current pixel of the tile) are sent to the multiplexer, to mix with the current pixel of the sprite.

The circuit also deals with getting sprite patterns and their V inversion (the H inversion circuit is in [OAM FIFO](fifo.md)).

Due to the large size, it will be difficult to show the entire diagram, so naturally we will saw it into its component parts.

Below is shown what circuits the Data Reader consists of, in order to understand where to look for the sawn pieces of circuits:

![ppu_dataread_sections](/BreakingNESWiki/imgstore/ppu_dataread_sections.jpg)

[PAR Address Generator](pargen.md) and [BG COL color generator](bgcol.md) have moved to their own sections.

## Pattern Readout

![ppu_dataread_pattern_readout](/BreakingNESWiki/imgstore/ppu_dataread_pattern_readout.jpg)

## V. Inversion

![ppu_dataread_vinv](/BreakingNESWiki/imgstore/ppu_dataread_vinv.jpg)
