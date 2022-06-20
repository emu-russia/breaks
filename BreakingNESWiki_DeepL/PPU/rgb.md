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

## CRAM

![COLOR_RAM](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_RAM.png)

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

## COLOR_DECODER_BLUE

![SEL16x12_BLUE](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_BLUE.png)

|Output|Bitmask|
|---|---|
|0|0b1001101101101000|
|1|0b1101101000010001|
|2|0b0110000100100010|
|3|0b1011100010011001|
|4|0b0001111001101111|
|5|0b1101001000100001|
|6|0b1101100110101010|
|7|0b1000101010011001|
|8|0b1001110101101010|
|9|0b1100000010100000|
|10|0b1101100110100010|
|11|0b1000101011001011|

## COLOR_DECODER_GREEN

![SEL16x12_GREEN](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_GREEN.png)

|Output|Bitmask|
|---|---|
|0|0b1001010111001010|
|1|0b0101100001010101|
|2|0b1111000101101111|
|3|0b0100110000101000|
|4|0b0111100011000111|
|5|0b1101011010000101|
|6|0b1110010000001101|
|7|0b0000001010111110|
|8|0b1000010111011010|
|9|0b1100010101000101|
|10|0b1001010000101010|
|11|0b0010001011011010|

## COLOR_DECODER_RED

![SEL16x12_RED](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_RED.png)

|Output|Bitmask|
|---|---|
|0|0b1001000111101010|
|1|0b1101010101110000|
|2|0b1111110101001111|
|3|0b1001100110000101|
|4|0b0010000111111110|
|5|0b1101001001001001|
|6|0b0011010101100111|
|7|0b0001001110100000|
|8|0b1110000111111010|
|9|0b1100001101000000|
|10|0b0110100101101001|
|11|0b1001011101100000|

## RGB_DAC

![RGB_DACs](/BreakingNESWiki/imgstore/ppu/rgb/RGB_DACs.png)

## /SYNC

![RGB_SYNC](/BreakingNESWiki/imgstore/ppu/rgb/RGB_SYNC.png)

![nSYNC_PAD](/BreakingNESWiki/imgstore/ppu/rgb/nSYNC_PAD.png)
