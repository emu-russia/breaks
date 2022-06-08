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

It is based on the 2C02G FSM.

![HV_FSM](/BreakingNESWiki/imgstore/ppu/rgb/HV_FSM.png)

The `BURST` signal circuit is present, but not the signal itself is not used.

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

## COLOR_DECODER_GREEN

![SEL16x12_GREEN](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_GREEN.png)

## COLOR_DECODER_RED

![SEL16x12_RED](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_RED.png)

## RGB_DAC

![RGB_DACs](/BreakingNESWiki/imgstore/ppu/rgb/RGB_DACs.png)

## /SYNC

![RGB_SYNC](/BreakingNESWiki/imgstore/ppu/rgb/RGB_SYNC.png)

![nSYNC_PAD](/BreakingNESWiki/imgstore/ppu/rgb/nSYNC_PAD.png)
