# OAM FIFO

![ppu_locator_fifo](/BreakingNESWiki/imgstore/ppu/ppu_locator_fifo.jpg)

The sprite FIFO is used to temporarily store up to 8 sprites that hit the current row.

It doesn't actually store the entire sprite, but only one line (8 pixels), the priority bit and 2 palette selection bits (attributes) and the X-coordinate.

Note on the term "FIFO": in fact, this component is not explicitly called that anywhere, but the authors considered it convenient to use this term in the perspective of the order in which sprites are displayed on the screen. The PPU patent refers to this circuit as `Motion picture buffer memory`.

![FIFO_All](/BreakingNESWiki/imgstore/ppu/FIFO_All.png)

## How it works

FIFO consists of 8 "lanes". Each lane consists of 3 parts: the pixel down-counter, the sprite attributes and the paired shift register.

The down-counter is loaded by the horizontal offset of the sprite and counts down to 0 at the same time as the pixels are rendered. Once the counter reaches 0, it means that you can start rendering the pixels of the sprite.

The attributes store 2 bits of sprite palette selection and 1 bit of priority over the background. These values are used for the entire output line.

The shift register is used to "push out" the next pixel in the sprite. It is paired because 2 bits of color are used for the pixel.

The sprite FIFO is loaded from the special temporary OAM memory (the one which is 32 bytes), during the horizontal synchronization (HBlank).

The schematics show only the lane for sprite #0. All other lanes differ only in the name of the signals.

![FIFO_Lane](/BreakingNESWiki/imgstore/ppu/FIFO_Lane.png)

## Down Counter Control

The circuit shown is for sprite #0. For all others (1-7) you must replace the name of the #0/EN signals with #x/EN.

![fifo_counter_control](/BreakingNESWiki/imgstore/ppu/fifo_counter_control.jpg)

![FIFO_CounterControl](/BreakingNESWiki/imgstore/ppu/FIFO_CounterControl.png)

## Down Counter

![fifo_counter](/BreakingNESWiki/imgstore/ppu/fifo_counter.jpg)

![FIFO_CounterBit](/BreakingNESWiki/imgstore/ppu/FIFO_CounterBit.png)

![FIFO_DownCounter](/BreakingNESWiki/imgstore/ppu/FIFO_DownCounter.png)

## Lane Control

The circuit for sprite #0 is shown. For all others (1-7) the signal names #0/EN, 0/COL2, 0/COL3 and 0/PRIO must be changed to #x/EN, x/COL2, x/COL3 and x/PRIO.

In addition, the H3'', H4'' and H5'' signals are used as decoder inputs to select the appropriate lanes:

|Sprite number (lane)|Signal logic H3'', H4'' and H5''|
|---|---|
|0|H3'' H4'' H5''| 
|1|/H3'' H4'' H5''|
|2|H3'' /H4'' H5''|
|3|/H3'' /H4'' H5''|
|4|H3'' H4'' /H5''|
|5|/H3'' H4'' /H5''|
|6|H3'' /H4'' /H5''|
|7|/H3'' /H4'' /H5''|

![fifo_attr](/BreakingNESWiki/imgstore/ppu/fifo_attr.jpg)

![FIFO_LaneControl](/BreakingNESWiki/imgstore/ppu/FIFO_LaneControl.png)

## Paired Shift Register

The circuit shown is for sprite #0. For all others (1-7) you must replace the signal names #0/COL0 and #0/COL1 with #x/COL0 and #x/COL1.

![fifo_sr](/BreakingNESWiki/imgstore/ppu/fifo_sr.jpg)

![FIFO_SRBit](/BreakingNESWiki/imgstore/ppu/FIFO_SRBit.png)

![FIFO_PairedSR](/BreakingNESWiki/imgstore/ppu/FIFO_PairedSR.png)

## Sprite Priority

The priority circuit is in "sparse" layout. The individual pieces of this circuit are shown below.
The circuit is a priority encoder.

![fifo_prio0](/BreakingNESWiki/imgstore/ppu/fifo_prio0.jpg)

![fifo_prio1](/BreakingNESWiki/imgstore/ppu/fifo_prio1.jpg)

![fifo_prio2](/BreakingNESWiki/imgstore/ppu/fifo_prio2.jpg)

![fifo_prio3](/BreakingNESWiki/imgstore/ppu/fifo_prio3.jpg)

![fifo_prio4](/BreakingNESWiki/imgstore/ppu/fifo_prio4.jpg)

The result of the circuit operation (output) is the `/SPR0HIT` signal, which goes to the corresponding Sprite 0 Hit circuit (see [multiplexer](mux.md))

![FIFO_Priority](/BreakingNESWiki/imgstore/ppu/FIFO_Priority.png)

## H. Inversion

![hinv](/BreakingNESWiki/imgstore/ppu/hinv.jpg)

HINV and HDIR are two complementary signals (they can never take the same value). Essentially these two signals are one multiplexer control signal which selects how the PD bus bits are output. If HINV = 1 this means that the PD bus bits are output in reverse order to the `/T0-7` outputs. If HDIR = 1 it means that the PD bus bits are output in straight order on the `/T0-7` outputs.

![H_Inversion](/BreakingNESWiki/imgstore/ppu/H_Inversion.png)

## Sprite H

It was also decided to include a small circuit for getting `/SHx` values (Sprite H) as part of the FIFO. The circuit is above the multiplexer, but most of the `/SHx` outputs are used only in the OAM FIFO (`/SH2` is also used in the Data Reader).

![sprite_h](/BreakingNESWiki/imgstore/ppu/sprite_h.jpg)

![SpriteH](/BreakingNESWiki/imgstore/ppu/SpriteH.png)
