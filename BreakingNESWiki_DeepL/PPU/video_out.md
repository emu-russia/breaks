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

## Chrominance Decoder

![vout_phase_decoder](/BreakingNESWiki/imgstore/ppu/vout_phase_decoder.jpg)

![vidout_chroma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_chroma_decoder_logic.jpg)

The color decoder selects one of the 12 phases. 12 because:
- No phase is required for black.
- There is no phase for colors 13-15. However, for color 13 there is an option to use brightness, and colors 14-15 are forced to be "Black" using the `PBLACK` signal

Table of matching decoder outputs and PPU colors:

|Color decoder output|Corresponding PPU color|
|---|---|
|0|12|
|1|5|
|2|10|
|3|3|
|4|0. Not connected to the phase shifter because gray halftones do not need a phase.|
|5|8. Also used for the Color Burst phase|
|6|1|
|7|6|
|8|11|
|9|4|
|10|9|
|11|2|
|12|7|

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
