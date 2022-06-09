# Video Signal Generator

![ppu_locator_vid_out](/BreakingNESWiki/imgstore/ppu/ppu_locator_vid_out.jpg)

![vidout_logic](/BreakingNESWiki/imgstore/ppu/vidout_logic.jpg)

Input signals:

|Signal|From|Description|
|---|---|---|
|/CLK|CLK Pad|First half of the PPU cycle|
|CLK|CLK Pad|Second half of the PPU cycle|
|/PCLK|PCLK Distribution|First half of the Pixel Clock cycle|
|PCLK|PCLK Distribution|Second half of the Pixel Clock cycle|
|RES|/RES Pad|Global reset|
|#CC0-3|Color Buffer|4 bits of the chrominance of the current "pixel" (inverted value)|
|#LL0-1|Color Buffer|2 bits of the luminance of the current "pixel" (inverted value)|
|BURST|FSM|Color Burst|
|SYNC|FSM|Sync pulse|
|/PICTURE|FSM|Visible part of the scan-lines|
|/TR|Regs $2001\[5\]|"Tint Red". Modifying value for Emphasis|
|/TG|Regs $2001\[6\]|"Tint Green". Modifying value for Emphasis|
|/TB|Regs $2001\[7\]|"Tint Blue". Modifying value for Emphasis|

## Phase Shifter

![vout_phase_shifter](/BreakingNESWiki/imgstore/ppu/vout_phase_shifter.jpg)

![vidout_phase_shifter_logic](/BreakingNESWiki/imgstore/ppu/vidout_phase_shifter_logic.jpg)

Schematic of a single bit shift register used in the phase shifter circuit:

![vidout_sr_bit_logic](/BreakingNESWiki/imgstore/ppu/vidout_sr_bit_logic.jpg)

If you dump each half-cycle phase shifter outputs and match them to the PPU color number with which it is associated, you get this:

```
123456......
12345......C
1234......BC
123......ABC
12......9ABC
1......89ABC
......789ABC
.....6789AB.
....56789A..
...456789...
..345678....
.234567.....
```

If you split the dump from the beginning of the PPU into pixels (8 half-cycles per pixel, according to the PCLK divider), you get the following:

```
.2.4.6.8.A.C
.2.4.6.8.A..
.2.456.8.A..
.2.456.8....
.23456.8....
.23456......
123456......
12345......C

1234......BC
123......ABC
12......9ABC
1......89ABC
......789ABC
.....6789AB.
....56789A..
...456789...

..345678....
.234567.....
123456......
12345......C
1234......BC
123......ABC
12......9ABC
1......89ABC

......789ABC
.....6789AB.
....56789A..
...456789...
..345678....
.234567.....
123456......
12345......C
```

That is, the first pixel phase shifter first "comes to its senses", and then begins to output 12 phases. Note that the phases do not correspond to the "boundaries" of the pixels, so the phase will "float". But since all phases "float" simultaneously with the phase that is used for Color Burst - the overall phase pattern will not be disturbed.

![cb_drift](/BreakingNESWiki/imgstore/ppu/cb_drift.png)

## Chrominance Decoder

![vout_phase_decoder](/BreakingNESWiki/imgstore/ppu/vout_phase_decoder.jpg)

![vidout_chroma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_chroma_decoder_logic.jpg)

The color decoder selects one of the 12 phases. 12 because:
- Gray halftones do not need a phase.
- There is no phase for colors 13-15. However, for color 13 there is an option to use brightness, and colors 14-15 are forced to be "Black" using the `PBLACK` signal

Table of matching decoder outputs and PPU colors:

|Color decoder output|Corresponding PPU color|Phase shift|
|---|---|---|
|0|12|120°|
|1|5|270°|
|2|10|60°|
|3|3|210°|
|4|0. Not connected to the phase shifter because gray halftones do not need a phase.| |
|5|8. Also used for the Color Burst phase|0°|
|6|1|150°|
|7|6|300°|
|8|11|90°|
|9|4|240°|
|10|9|30°|
|11|2|180°|
|12|7|330°|

(The numbering of the decoder outputs is topological, from left to right, starting from 0).

## Luminance Level

|![vout_level_select](/BreakingNESWiki/imgstore/ppu/vout_level_select.jpg)|![vidout_luma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_luma_decoder_logic.jpg)|
|---|---|

The brightness decoder selects one of 4 brightness levels.

## Emphasis

|![vout_emphasis](/BreakingNESWiki/imgstore/ppu/vout_emphasis.jpg)|![vidout_emphasis_logic](/BreakingNESWiki/imgstore/ppu/vidout_emphasis_logic.jpg)|
|---|---|

If a dimming color is selected in the phase shifter and dimming for that color is enabled in the control register $2001, it activates the `TINT` signal, which slightly lowers the voltage levels, thereby dimming the color.

## DAC

![vout_dac](/BreakingNESWiki/imgstore/ppu/vout_dac.jpg)

![vidout_dac_logic](/BreakingNESWiki/imgstore/ppu/vidout_dac_logic.jpg)
