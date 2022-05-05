# Color RAM

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

The logic for working with the palette includes the following circuits:
- Color Buffer (CB)
- Color Buffer control circuitry
- Palette memory (Color RAM)
- Decoder of the palette index, coming from the output of the multiplexer

Signals:

|Signal|From|Purpose|
|---|---|---|
|/R7|Reg Select|Read $2007|
|/DBE|/DBE Pad|"Data Bus Enable", enable CPU interface|
|TH/MUX|VRAM Ctrl|Send the TH Counter value to the MUX input, which will cause the value to go into the palette as Direct Color.|
|/PICTURE|FSM|The visible part of the video signal with the picture is generated|
|B/W|Regs $2001\[0\]|Disable Color Burst, to generate a monochrome picture|
|DB/PAR|VRAM Ctrl|Control signal|
|#DB/CB|Color Buffer Control|0: DB -> CB|
|#CB/DB|Color Buffer Control|0: CB -> DB|

## Color Buffer (CB)

The Color Buffer (CB) is used to store the current "pixel" for the phase generator and to read/write the palette memory (using the CPU interface).

### Color Buffer Control

![cb_control](/BreakingNESWiki/imgstore/ppu/cb_control.jpg)

![CB_Control_Logic](/BreakingNESWiki/imgstore/ppu/CB_Control_Logic.jpg)

### CB Bit

|![color_buffer_bit](/BreakingNESWiki/imgstore/ppu/color_buffer_bit.jpg)|![cb_bit_logisim](/BreakingNESWiki/imgstore/ppu/cb_bit_logisim.jpg)|
|---|---|

The Logisim schematic is a very approximation of the original one, because Logisim does not support inOut entities.

### CB Output Delay

The outputs from the CB bits do not go directly to the phase generator, but go through a D-Latch chain. The D-Latch chains are unequally spaced for each CB bit.

Delays are necessary due to the fact that logically it is not possible to process the current pixel and simultaneously display it as a signal. Therefore, the video generator essentially outputs pixels "from the past".

For CB bits 4-5 (luminance, LL0# and LL1# signals):

![cbout_ll](/BreakingNESWiki/imgstore/ppu/cbout_ll.jpg)

For CB bits 0-3 (chrominance, CC0-3# signals), only part of the chain is next to the CB. The rest of the latches are scattered like breadcrumbs along the way to [phase generator](video_out.md).

![cbout_cc](/BreakingNESWiki/imgstore/ppu/cbout_cc.jpg)

P.S. If you are a chip designer, please don't spread your topology out like this. Such circuits are very inconvenient to saw into pieces for study and post on the wiki.

### Black/White Mode

The outputs of the 4 bit CB responsible for the chrominance are controlled by the `/BW` control signal.

A similar transistor for the 2 luminance bits is simply always open:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu/ppu_luma_tran.jpg)

## Color RAM Layout

By convention, groups of cells that are addressed by the lowest bits of the address will be considered "rows", and groups of cells that are addressed by the highest bits will be considered "columns".

Color RAM:
- PAL3, PAL2: Defines column (PAL2 - msb)
- PAL4, PAL1, PAL0: Defines a row (PAL4 - msb)
- Rows 0 and 4 combined

It looks a bit chaotic, but it is what it is. Reverse engineering of memory for some reason always goes with this kind of agony of understanding, but don't forget the fact that the order in which the address lines are connected for memory indexing is generally irrelevant.

COL outputs:

![palette_col_outputs](/BreakingNESWiki/imgstore/ppu/palette_col_outputs.jpg)

PCLK Precharge:

![cram_precharge](/BreakingNESWiki/imgstore/ppu/cram_precharge.jpg)

### Memory Cell

The memory cell is a typical 4T SRAM Cell:

|![cram_cell_topo](/BreakingNESWiki/imgstore/ppu/cram_cell_topo.jpg)|![cram_cell](/BreakingNESWiki/imgstore/ppu/cram_cell.jpg)|
|---|---|

The value is written or read with two complementary inOut: /val and val. The principle of cell operation:
- In cell read mode: /val = val = `z`. Therefore, the current value is output to the outside.
- In cell write mode: /val and val take the complementary value of the bit to be written

### CRAM Index Decoder

:warning: Note that the PAL4 signal does not follow the usual order. This bit selects the type of palette: palette for the background or for the sprites.

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
