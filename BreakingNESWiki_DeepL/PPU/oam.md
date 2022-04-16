# OAM

![ppu_locator_oam](/BreakingNESWiki/imgstore/ppu/ppu_locator_oam.jpg)

Sprite memory (OAM, Object Attribute Memory) takes up almost a quarter of the PPU's surface, which was a luxury in those days. The size of the OAM is 2112 bits, of which 1856 are used to store 64 sprites (29 bits per sprite) and the remaining 32 bytes are used in a special way to sample the 8 current sprites to be shown on the current line. This area of the OAM is usually called "temporary OAM" or OAM2.

Сombined image of the memory cell topology:

![ppu_oam_closeup](/BreakingNESWiki/imgstore/ppu/ppu_oam_closeup.jpg)

OAM circuits:
- Memory Cell Array (2112 cells)
- Row Decoder
- Column Decoder
- OAM Buffer control circuit
- OAM Buffer (OB)

## OAM Layout

TBD: This is where you need to write how the cells are stacked and how the memory is addressed.

## Memory Cell

![oam_cell](/BreakingNESWiki/imgstore/ppu/oam_cell.jpg)

The cell is a typical 4T cell, but with one exception - the transistors of the cell where the value is stored are not connected to Vdd, so the value on the cell is constantly degrading because without a pull-up it is essentially stored on the gate of the transistors.

The OAM memory degradation effect is called "OAM Corruption" and it is widely known. To combat this effect, programs for the NES contain an OAM cache in regular CPU memory and every VBlank copies this cache to OAM using the APU's sprite DMA.

TBD: Calculate or measure cell degradation timings.

## Row Decoder

![oam_row_decoder](/BreakingNESWiki/imgstore/ppu/oam_row_decoder.png)

The circuit is a 1-of-n decoder.

ROW outputs for OAM Buffer bits 0, 1, 5-7:

![oam_row_outputs1](/BreakingNESWiki/imgstore/ppu/oam_row_outputs1.png)

ROW outputs for OAM Buffer bits 2-4:

![oam_row_outputs2](/BreakingNESWiki/imgstore/ppu/oam_row_outputs2.png)

The skipping of rows at bits 2-4 is done to save memory. If we match the OAM address with the ROW values, which are obtained from the lowest bits, we get the following:

```
OamAddr: 0, row: 0
OamAddr: 1, row: 1
OamAddr: 2, row: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 3, row: 3
OamAddr: 4, row: 4
OamAddr: 5, row: 5
OamAddr: 6, row: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 7, row: 7
OamAddr: 8, row: 0
OamAddr: 9, row: 1
OamAddr: 10, row: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 11, row: 3
OamAddr: 12, row: 4
OamAddr: 13, row: 5
OamAddr: 14, row: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 15, row: 7
...
```

As you can see ROW2 and ROW6 fall just on the attribute byte of the sprite, which does not use bits 2-4.

## Column Decoder

![oam_col_decoder](/BreakingNESWiki/imgstore/ppu/oam_col_decoder.png)

The circuit is a 1-of-n decoder.

## OAM Buffer Control

The circuit is used to set the operating modes of the OB and to control the transfer of values between it and the OAM.

![oam_buffer_control](/BreakingNESWiki/imgstore/ppu/oam_buffer_control.jpg)

## OAM Buffer (OB)

The OAM Buffer is used as a transfer point to store a byte that needs to be written to the OAM or a byte that has been read from the OAM for consumers.

The circuit consists of 8 identical circuits for each bit:

![oam_buffer_bit](/BreakingNESWiki/imgstore/ppu/oam_buffer_bit.jpg)

(The picture shows the circuit for storing the OB0 bit).

The data from OB goes through a small Readback circuit:

![oam_buffer_readback](/BreakingNESWiki/imgstore/ppu/oam_buffer_readback.jpg)
