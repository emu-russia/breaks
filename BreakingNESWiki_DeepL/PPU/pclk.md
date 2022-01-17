# Pixel Clock (PCLK)

Pixel clock (abbreviated as PCLK) is used by all PPU parts (except the video phase generator).

Both low level (`/PCLK`) and high level (`PCLK`) are used symmetrically. This approach of internal cycle implementation was widespread in the era of NMOS chips. Therefore, when analyzing PPU circuits, one should not think of PCLK as the clock signal, but rather the two "states" - PCLK=0 and PCLK=1.

Conventionally, `/PCLK` may be called "preparation" and `PCLK` may be called "pixel output".

The `PCLK` is obtained by slowing down (dividing) the input clock signal `CLK` (21.48 MHz) by a factor of 4.

For this purpose, a divider on static latches is used:

<img src="/BreakingNESWiki/imgstore/pclk.jpg" width="400px">

Just below the divider is a small circuit. There is the soul of the PPU and we will not examine it.

At the output of the divider there are many push/pull amplifier stages, because the `PCLK` signal must be powerful enough, because it is distributed practically over the whole chip. For this purpose (just to the right of the chip) there is a comb of even more powerful push/pull inverters:

![pclk_amp](/BreakingNESWiki/imgstore/pclk_amp.jpg)

The `CLK` input clock signal is used exclusively in the [phase generator](video_out.md) of the PPU video path.

Timings:

|PPU|CLK|CLK Cycle Duration|PCLK|PCLK Cycle Duration|
|---|---|---|---|---|
|NTSC|21477272 Hz|~0,046 µs|5369318 Hz|~0,186 µs|
|PAL|26601712 Hz|~0,037 µs|5320342.4 Hz|~0,187 µs|

## Power On Status

It is hard to say what values are on the latches (gates). If we assume that after power-up `CLK` is 0 and `z` (in HDL terms meaning "disconnected") on the gate is the same as 0 (gate closed), then the latch values will take the following values: [ 0, 1, 0, 1 ]

(The first latch is next to the `RES` signal.)

But in general it is more correct to assume that the value of the latches is undefined (`x`)
