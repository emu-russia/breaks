# RGB PPU

This section discusses the differences between the RGB PPU RP2C04-0003, and the reference PPU 2C02G.

At the moment, these are the only images of RGB PPU that we have. However, there are pictures of only the top layer, so it is not always good to see what is underneath. Something was partly visible, partly guessed, so here it looks more like a Japanese puzzle.

List of major differences:
- EXT0-3 and VOUT pins are replaced by RED, GREEN, BLUE, /SYNC pins, for component video signal output.
- An RGB encoding circuit is used instead of a composite video generator. DAC with weighted current summation.
- Emphasis applies the corresponding channel output to all one's
- There is no possibility to read OAM (no `/R4` register operation), for this reason the OAM Buffer is arranged simpler
- There is no possibility to read CRAM, for this reason the Color Buffer is simpler

There is an assumption that the other RGB PPUs are not very different from the 2C04-0003, so this section will be updated as photos of other RGB PPU revisions become available.

|Number|2C02G Terminal|RGB PPU Terminal|
|---|---|---|
|14|EXT0|RED|
|15|EXT1|GREEN|
|16|EXT2|BLUE|
|17|EXT3|AGND|
|21|VOUT|/SYNC|

The following will simply be restored schematics. The original RGB PPU images can be found here: https://siliconpr0n.org/map/nintendo/rp2c04-0003/

![2C04-0003_RGB_PPU](/BreakingNESWiki/imgstore/ppu/rgb/2C04-0003_RGB_PPU.png)

## FSM

It is based on the 2C02 FSM.

![HV_FSM](/BreakingNESWiki/imgstore/ppu/rgb/HV_FSM.png)

The `BURST` signal circuit is present, but the signal itself is not used.

![FSM_BURST](/BreakingNESWiki/imgstore/ppu/rgb/FSM_BURST.jpg)

## EVEN/ODD

The Even/Odd circuit is present but disconnected, the NOR input where the `EvenOddOut` signal came is grounded.

![evenodd_rgb](/BreakingNESWiki/imgstore/ppu/rgb/evenodd_rgb.png)

![evdd](/BreakingNESWiki/imgstore/ppu/rgb/evdd.png)

## COLOR_CONTROL

![COLOR_CONTROL](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_CONTROL.png)

## COLOR_BUFFER_BIT

![CB_BIT](/BreakingNESWiki/imgstore/ppu/rgb/CB_BIT.png)

## CRAM

![COLOR_RAM](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_RAM.png)

![COLOR_IO_RGB](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_IO_RGB.png)

## REG_SELECT

![REG_SELECT](/BreakingNESWiki/imgstore/ppu/rgb/REG_SELECT.png)

## CONTROL_REGS

The `/SLAVE` signal is not used.

![Control_REGs](/BreakingNESWiki/imgstore/ppu/rgb/Control_REGs.png)

## MUX

The input signals `EXT_IN` are `0` and the output signals `/EXT_OUT` are not used.

![MUX](/BreakingNESWiki/imgstore/ppu/rgb/MUX.png)

## OAM_BUF_CONTROL

Reduced write delay. The number of latches is 2 less compared to the composite PPU revisions.

![OAM_BUF_CONTROL](/BreakingNESWiki/imgstore/ppu/rgb/OAM_BUF_CONTROL.png)

## OAM_BIT

![2C04_OAM_buf](/BreakingNESWiki/imgstore/ppu/rgb/2C04_OAM_buf.jpg)

## Video Out

![RGB_VIDEO_OUT](/BreakingNESWiki/imgstore/ppu/rgb/RGB_VIDEO_OUT.png)

## SEL_12x3

![SEL12x3](/BreakingNESWiki/imgstore/ppu/rgb/SEL12x3.png)

FF:

![SEL12x3_FF](/BreakingNESWiki/imgstore/ppu/rgb/SEL12x3_FF.png)

## COLOR_DECODER_RED

![SEL16x12_RED](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_RED.png)

|Output|Bitmask|
|---|---|
|0|1010100001110110|
|1|1111000101010100|
|2|0000110101000000|
|3|0101111001100110|
|4|1000000001111011|
|5|0110110110110100|
|6|0001100101010011|
|7|1111101000110111|
|8|1010000001111000|
|9|1111110100111100|
|10|0110100101101001|
|11|1111100100010110|

(lsb first, 1 means there is a transistor, 0 means there is no transistor)

## COLOR_DECODER_GREEN

![SEL16x12_GREEN](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_GREEN.png)

|Output|Bitmask|
|---|---|
|0|1010110001010110|
|1|0101010111100101|
|2|0000100101110000|
|3|1110101111001101|
|4|0001110011100001|
|5|0101111010010100|
|6|0100111111011000|
|7|1000001010111111|
|8|1010010001011110|
|9|0101110101011100|
|10|1010101111010110|
|11|1010010010111011|

(lsb first, 1 means there is a transistor, 0 means there is no transistor)

## COLOR_DECODER_BLUE

![SEL16x12_BLUE](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_BLUE.png)

|Output|Bitmask|
|---|---|
|0|1110100100100110|
|1|0111011110100100|
|2|1011101101111001|
|3|0110011011100010|
|4|0000100110000111|
|5|0111101110110100|
|6|1010101001100100|
|7|0110011010101110|
|8|1010100101000110|
|9|1111101111111100|
|10|1011101001100100|
|11|0010110010101110|

(lsb first, 1 means there is a transistor, 0 means there is no transistor)

## RGB_DAC

![RGB_DACs](/BreakingNESWiki/imgstore/ppu/rgb/RGB_DACs.png)

## /SYNC

![RGB_SYNC](/BreakingNESWiki/imgstore/ppu/rgb/RGB_SYNC.png)

![nSYNC_PAD](/BreakingNESWiki/imgstore/ppu/rgb/nSYNC_PAD.png)
