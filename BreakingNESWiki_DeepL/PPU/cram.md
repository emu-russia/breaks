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

COL outputs:

![palette_col_outputs](/BreakingNESWiki/imgstore/ppu/palette_col_outputs.jpg)

Precharge PCLK:

![palette_precharge](/BreakingNESWiki/imgstore/ppu/palette_precharge.jpg)

### Memory Cell

|![cram_cell_topo](/BreakingNESWiki/imgstore/ppu/cram_cell_topo.jpg)|![cram_cell](/BreakingNESWiki/imgstore/ppu/cram_cell.jpg)|
|---|---|

### CRAM Index Decoder

|![ppu_palette_decoder](/BreakingNESWiki/imgstore/ppu/ppu_palette_decoder.jpg)|![cram_decoder_logic](/BreakingNESWiki/imgstore/ppu/cram_decoder_logic.jpg)|
|---|---|

|COL0|COL1|COL2|COL3|
|---|---|---|---|
|ROW0+4||||
|ROW6||||
|ROW2||||
|ROW5||||
|ROW1||||
|ROW7||||
|ROW3||||
