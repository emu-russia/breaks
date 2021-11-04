# Palette

The logic for working with the palette includes the following circuits:
- Color Buffer (CB)
- Color Buffer control circuitry
- Palette memory
- Decoder of the palette index, coming from the output of the multiplexer

## Color Buffer (CB)

The Color Buffer (CB) is used to store the current "pixel" for the phase generator and to read/write the palette memory (using the CPU interface).

### Color Buffer Control

![ppu_cb_control](/BreakingNESWiki/imgstore/ppu_cb_control.jpg)

![ppu_logisim_color_control](/BreakingNESWiki/imgstore/ppu_logisim_color_control.jpg)

### CB Bit

![ppu_color_buffer_bit](/BreakingNESWiki/imgstore/ppu_color_buffer_bit.jpg)

![ppu_logisim_cb_bit](/BreakingNESWiki/imgstore/ppu_logisim_cb_bit.jpg)

### CB Output Delay

The outputs from the CB bits do not go directly to the phase generator, but go through a D-Latch chain. The D-Latch chains are unequally spaced for each CB bit.

TBD.

### Black/White Mode

The outputs of the 4 bit CB responsible for the chrominance are controlled by the /BW control signal.

A similar transistor for the 2 luminance bits is simply always open:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu_luma_tran.jpg)

## Palette RAM Layout

COL outputs:

![ppu_palette_col_outputs](/BreakingNESWiki/imgstore/ppu_palette_col_outputs.jpg)

Precharge PCLK:

![ppu_palette_precharge](/BreakingNESWiki/imgstore/ppu_palette_precharge.jpg)

### Memory Cell

![ppu_palette_cell](/BreakingNESWiki/imgstore/ppu_palette_cell.jpg)

### Palette Index Decoder

![ppu_palette_decoder](/BreakingNESWiki/imgstore/ppu_palette_decoder.jpg)
