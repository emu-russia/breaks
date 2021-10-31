# Multiplexer

The PPU multiplexer is the little wicked circuit that deals with the selection of the pixel color, which is then fed to the palette memory input as an index, to select the final color for the [phase generator](video_out.md).

As usual, "color" and "pixel" are understood as abstract concepts: color is the color/brightness combination for the phase generator, and pixel is part of the visible video signal.

Inputs:
- Backround color (4 bits)
- Sprite color (4 bits)
- Color from external contacts (EXT In) (4 bits)
- Direct color from TH (5 bits)

Outputs:
- Color Index for Palette (5 bits)
- Color for external contacts (EXT Out) (4 bits)

## Transistor circuit

![ppu_mux](/BreakingNESWiki/imgstore/ppu_mux.jpg)

As you can see, the circuit looks very confusing at first glance. This is because the multipliers (as circuit elements) are very difficult to recognize from the NMOS transistors.

## Logisim Circuit

![ppu_mux_logisim](/BreakingNESWiki/imgstore/ppu_mux_logisim.jpg)

(A piece of circuitry for the Sprite 0 Hit test is not shown and is marked as "to strike test").

Signals:

|Signal|Purpose|
|---|---|
|BGC0-3|The color of the background
|ZCOL0-3|Sprite color|
|EXT0-3 IN|Input color from EXT pins|
|THO0-4|Input color from TH|
|TH/MUX|Prioritizes the direct color from TH over all other colors|
|ZPRIO|Prioritizes the sprite color over the background color|
|EXT0-3 OUT|The output color for EXT contacts|
|PAL0-4|Output color for palette indexing|

As you can see the circuit is a cascade of multiplexers, between which are D-Latch:
- The first state selects the color of the background/sprite. Which color is selected is determined by the circuit by the bits BGC0-1, ZCOL0-1 and the priority of the sprites (ZPRIO). The result of this circuitry is an internal `OCOL` control signal that is applied to the bit multiplexers;
- In the second state a choice is made between the previous result and the external color from the EXT pins;
- In the third state a choice is made between the result of the second state and the direct color from the TH (Tile Horizontal) counter. The priority of the direct color is set by the control signal `TH/MUX` (more details about this will be added, after considering the scheme [Data Reader](dataread.md), where TH is located).

"Direct color" looks intriguing because it sounds like the ability to output direct bitmap images, bypassing the PPU tile/sprite graphics features. This question needs more research.

## Sprite 0 Hit

Sprite 0 Hit is an alien PPU feature.

This feature is designed to detect when sprite #0 has "crossed over" to the background.

This event is stored as a bit of register $2002[6].

This feature can be used by the programmer to determine when a certain point on the screen is rendered:
- Sprite #0 is set to a certain position
- Polling of register $2002[6] is done.
- The program performs additional actions when Sprite 0 Hit is detected.

This is usually used to create "Split Screen" effects.

Sprite 0 Hit circuit:

![spr0hit](/BreakingNESWiki/imgstore/spr0hit.jpg)

The control output `STRIKE` is 1 only when BGC0=1 or BGC=1 with all other inputs set to 0.

The control signal `SPR0HIT` comes from the sprite priority control circuit (see [OAM FIFO](fifo.md)) and the control signal `LOL` (its exact meaning is not yet known) from [sprite comparison circuit](sprite_eval.md).
