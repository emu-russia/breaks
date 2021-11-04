# OAM

Sprite memory (OAM, Object RAM) takes up almost a quarter of the PPU's surface, which was a luxury in those days. The size of the OAM is 2112 bits, of which 1856 are used to store 64 sprites (29 bits per sprite) and the remaining 32 bytes are used in a special way to sample the 8 current sprites to be shown on the current line. This area of the OAM is usually called "temporary OAM" or OAM2.

Sprite memory layout on the chip and a combined image of the memory cell topology:

<img src="/BreakingNESWiki/imgstore/ppu_oam_preview.jpg" width="280px"> <img src="/BreakingNESWiki/imgstore/ppu_oam_closeup.jpg" width="400px">

OAM circuits:
- Memory Cell Array (2112 cells)
- Column Decoder
- Row Decoder
- OAM Buffer (OB)
- OAM Buffer control circuit

## OAM Layout

TBD: This is where you need to write how the cells are stacked and how the memory is addressed.

## Memory Cell

![oam_cell](/BreakingNESWiki/imgstore/oam_cell.jpg)

The cell is a typical 4T cell, but with one exception - the transistors of the cell where the value is stored are not connected to Vdd, so the value on the cell is constantly degrading because without a pull-up it is essentially stored on the gate of the transistors.

The OAM memory degradation effect is called "OAM Corruption" and it is widely known. To combat this effect, programs for the NES contain an OAM cache in regular CPU memory and every VBlank copies this cache to OAM using the APU's sprite DMA.

TBD: Calculate or measure cell degradation timings.

## Column Decoder

![oam_cas](/BreakingNESWiki/imgstore/oam_cas.jpg)

The circuit is a 1-of-n decoder.

COL outputs for OAM Buffer bits 0, 1, 5-7:

![oam_col_outputs1](/BreakingNESWiki/imgstore/oam_col_outputs1.jpg)

COL outputs for OAM Buffer bits 2-4:

![oam_col_outputs2](/BreakingNESWiki/imgstore/oam_col_outputs2.jpg)

## Row Decoder

![oam_ras](/BreakingNESWiki/imgstore/oam_ras.jpg)

The circuit is a 1-of-n decoder.

## OAM Buffer (OB)

The OAM Buffer is used as a transfer point to store a byte that needs to be written to the OAM or a byte that has been read from the OAM for consumers.

The circuit consists of 8 identical circuits for each bit:

![oam_buffer_bit](/BreakingNESWiki/imgstore/oam_buffer_bit.jpg)

(The picture shows the circuit for storing the OB0 bit).

The data from OB goes through a small Readback circuit:

![oam_buffer_readback](/BreakingNESWiki/imgstore/oam_buffer_readback.jpg)

## OAM Buffer Control

The circuit is used to set the operating modes of the OB and to control the transfer of values between it and the OAM.

![oam_buffer_control](/BreakingNESWiki/imgstore/oam_buffer_control.jpg)
