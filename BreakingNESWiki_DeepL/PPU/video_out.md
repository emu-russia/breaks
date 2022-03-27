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
|#CC0-3|Color Buffer|4 bits of the chrominance of the current "pixel"|
|#LL0-1|Color Buffer|2 bits of the luminance of the current "pixel"|
|BURST|FSM|Color Burst|
|HSYNC|FSM|Horizontal sync pulse|
|PICTURE|FSM|Visible part of the scan-lines|
|/TR|Regs $2001\[5\]|"Tint Red". Modifying value for Emphasis|
|/TG|Regs $2001\[6\]|"Tint Green". Modifying value for Emphasis|
|/TB|Regs $2001\[7\]|"Tint Blue". Modifying value for Emphasis|

## Phase Shifter

![vout_phase_shifter](/BreakingNESWiki/imgstore/ppu/vout_phase_shifter.jpg)

![vidout_phase_shifter_logic](/BreakingNESWiki/imgstore/ppu/vidout_phase_shifter_logic.jpg)

## Chrominance Decoder

![vout_phase_decoder](/BreakingNESWiki/imgstore/ppu/vout_phase_decoder.jpg)

![vidout_chroma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_chroma_decoder_logic.jpg)

## Luminance Level

|![vout_level_select](/BreakingNESWiki/imgstore/ppu/vout_level_select.jpg)|![vidout_luma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_luma_decoder_logic.jpg)|
|---|---|

## Emphasis

|![vout_emphasis](/BreakingNESWiki/imgstore/ppu/vout_emphasis.jpg)|![vidout_emphasis_logic](/BreakingNESWiki/imgstore/ppu/vidout_emphasis_logic.jpg)|
|---|---|

## DAC

![vout_dac](/BreakingNESWiki/imgstore/ppu/vout_dac.jpg)

![vidout_dac_logic](/BreakingNESWiki/imgstore/ppu/vidout_dac_logic.jpg)
