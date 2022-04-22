# Data Reader

The PPU patent refers to this circuit as the `Still Picture Generator`.

The circuitry takes up almost a quarter of the PPU area and is located in the lower right corner of the chip:

![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/ppu_locator_dataread.jpg)

This circuit deals with sampling a row of 8 pixels, based on the scroll registers which set the position of the tile in the name table and the fine offset of the starting point within the tile.
The results (the current pixel of the tile) are sent to the multiplexer, to mix with the current pixel of the sprite.

The circuit also deals with getting sprite patterns and their V inversion (the H inversion circuit is in [OAM FIFO](fifo.md)).

Due to the large size, it will be difficult to show the entire diagram, so naturally we will saw it into its component parts.

Below is shown what circuits the Data Reader consists of, in order to understand where to look for the sawn pieces of circuits:

![ppu_dataread_sections](/BreakingNESWiki/imgstore/ppu/ppu_dataread_sections.jpg)

There was something in this section historically, but then it was split up into sections. The only thing left is the circuit for the generation of the tile address.

## Pattern Address Generator

The circuit takes up the whole upper part and forms the tile (`Pattern`) address, which is set by `/PAD0-12` (13 bits).

![ppu_dataread_pattern_readout](/BreakingNESWiki/imgstore/ppu/ppu_dataread_pattern_readout.jpg)

![ppu_dataread_vinv](/BreakingNESWiki/imgstore/ppu/ppu_dataread_vinv.jpg)

![PatGen](/BreakingNESWiki/imgstore/ppu/PatGen.png)

Small circuits to control the loading of values into the output latches. The main emphasis is on selecting the mode of operation for sprites/backgrounds (signal `PAR/O` - "PAR for Objects").

|![PatControl](/BreakingNESWiki/imgstore/ppu/PatControl.png)|![PatV_Inversion](/BreakingNESWiki/imgstore/ppu/PatV_Inversion.png)|
|---|---|

Bit circuits to form the output value `/PAD0-12` in slight variations:

|![PatBit](/BreakingNESWiki/imgstore/ppu/PatBit.png)|![PatBit4](/BreakingNESWiki/imgstore/ppu/PatBit4.png)|![PatBitInv](/BreakingNESWiki/imgstore/ppu/PatBitInv.png)|
|---|---|---|

## The Rest

The other parts of the schematic can be found in the corresponding sections:

- [Scrolling Registers](scroll_regs.md)
- [Picture Address Generator](pargen.md)
- [Background Color](bgcol.md)
