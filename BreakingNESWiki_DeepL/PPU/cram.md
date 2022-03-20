# Color RAM

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

The logic for working with the palette includes the following circuits:
- Color Buffer (CB)
- Color Buffer control circuitry
- Palette memory (Color RAM)
- Decoder of the palette index, coming from the output of the multiplexer

## Color Buffer (CB)

The Color Buffer (CB) is used to store the current "pixel" for the phase generator and to read/write the palette memory (using the CPU interface).

### Color Buffer Control

![ppu_cb_control](/BreakingNESWiki/imgstore/ppu/ppu_cb_control.jpg)

![ppu_logisim_color_control](/BreakingNESWiki/imgstore/ppu/ppu_logisim_color_control.jpg)

### CB Bit

![ppu_color_buffer_bit](/BreakingNESWiki/imgstore/ppu/ppu_color_buffer_bit.jpg)

![ppu_logisim_cb_bit](/BreakingNESWiki/imgstore/ppu/ppu_logisim_cb_bit.jpg)

### CB Output Delay

The outputs from the CB bits do not go directly to the phase generator, but go through a D-Latch chain. The D-Latch chains are unequally spaced for each CB bit.

TBD.

### Black/White Mode

The outputs of the 4 bit CB responsible for the chrominance are controlled by the /BW control signal.

A similar transistor for the 2 luminance bits is simply always open:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu/ppu_luma_tran.jpg)

## Color RAM Layout

By convention, groups of cells that are addressed by the lowest bits of the address will be considered "rows", and groups of cells that are addressed by the highest bits will be considered "columns".

Color RAM:
- PAL2, PAL3: Defines column (PAL2 - msb)
- PAL4, PAL1, PAL0: Defines a row (PAL4 - msb)
- Rows 0 and 4 combined

It looks a bit chaotic, but it is what it is. Reverse engineering of memory for some reason always goes with this kind of agony of understanding, but don't forget the fact that the order in which the address lines are connected for memory indexing is generally irrelevant.

COL outputs:

![palette_col_outputs](/BreakingNESWiki/imgstore/ppu/palette_col_outputs.jpg)

Precharge PCLK:

![cram_precharge](/BreakingNESWiki/imgstore/ppu/cram_precharge.jpg)

### Memory Cell

The memory cell is a typical 4T SRAM Cell:

|![cram_cell_topo](/BreakingNESWiki/imgstore/ppu/cram_cell_topo.jpg)|![cram_cell](/BreakingNESWiki/imgstore/ppu/cram_cell.jpg)|
|---|---|

### CRAM Index Decoder

|![cram_decoder](/BreakingNESWiki/imgstore/ppu/cram_decoder.jpg)|![cram_decoder_logic](/BreakingNESWiki/imgstore/ppu/cram_decoder_logic.jpg)|
|---|---|

|COL0 \| COL1 \| COL2 \| COL3|
|---|
|ROW0+4|
|ROW6|
|ROW2|
|ROW5|
|ROW1|
|ROW7|
|ROW3|

A similar memory organization pattern is repeated 6 times for each Color Buffer bit.
