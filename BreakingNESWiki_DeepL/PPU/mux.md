# Multiplexer

The PPU multiplexer is the little wicked circuit that deals with the selection of the pixel color, which is then fed to the palette memory input as an index, to select the final color for the [phase generator](video_out.md).

As usual, "color" and "pixel" are understood as abstract concepts: color is the color/brightness combination for the phase generator, and pixel is part of the visible video signal.

Inputs:
- Background color (4 bits)
- Sprite color (4 bits)
- Color from external contacts (EXT In) (4 bits)
- Direct color from PAR TH Counter (5 bits)

Outputs:
- Color Index for Palette (5 bits)
- Color for external contacts (EXT Out) (4 bits)

## Transistor Circuit

![ppu_mux](/BreakingNESWiki/imgstore/ppu_mux.jpg)

As you can see, the circuit looks very confusing at first glance. This is because the multiplexers (as circuit elements) are very difficult to recognize from the NMOS transistors.

## Logisim Circuit

![ppu_mux_logisim](/BreakingNESWiki/imgstore/ppu_mux_logisim.jpg)

(A piece of circuitry for the Sprite 0 Hit test is not shown and is marked as "to strike test").

Signals:

|Signal|Purpose|
|---|---|
|BGC0-3|The color of the background|
|ZCOL0-3|Sprite color|
|EXT0-3 IN|Input color from EXT pins|
|THO0-4|Input color from TH counter|
|TH/MUX|Prioritizes the direct color from TH over all other colors|
|ZPRIO|Prioritizes the sprite color over the background color|
|EXT0-3 OUT|The output color for EXT contacts|
|PAL0-4|Output color for palette indexing|

As you can see the circuit is a cascade of multiplexers, between which are D-Latch:
- The first state selects the color of the background/sprite. Which color is selected is determined by the circuit by the bits BGC0-1, ZCOL0-1 and the priority of the sprites (ZPRIO). The result of this circuitry is an internal `OCOL` control signal that is applied to the bit multiplexers;
- In the second state a choice is made between the previous result and the external color from the EXT pins;
- In the third state a choice is made between the result of the second state and the direct color from the TH (Tile Horizontal) counter. The priority of the direct color is set by the control signal `TH/MUX`.

"Direct color" is a special processing to access the palette memory from the CPU interface side. Since the palette memory is mapped to the PPU address space - when the palette is accessed, its index is temporarily stored on the PAR TH counter (5 bits). When this happens, the [VRAM controller](vram_ctrl.md) sets the TH/MUX signal, which indicates that the TH counter contains the selected palette index (color). The outputs from the TH counter (THO0-4) go to the multiplexer, which selects the desired palette index.

## Sprite 0 Hit

Sprite 0 Hit is an alien PPU feature.

This feature is designed to detect when sprite #0 has "crossed over" to the background.

This event is stored as a bit of register $2002\[6\].

This feature can be used by the programmer to determine when a certain point on the screen is rendered:
- Sprite #0 is set to a certain position
- Polling of register $2002\[6\] is done.
- The program performs additional actions when Sprite 0 Hit is detected.

This is usually used to create "Split Screen" effects.

Sprite 0 Hit circuit:

![spr0hit](/BreakingNESWiki/imgstore/spr0hit.jpg)

The control output `STRIKE` is 1 only when BGC0=1 or BGC1=1 with all other inputs set to 0.

The control signal `SPR0HIT` comes from the sprite priority control circuit (see [OAM FIFO](fifo.md)) and the control signal `I2SEV` from [sprite comparison circuit](sprite_eval.md).

## Multiplexer Tricks

Knowing the features of the multiplexer, you can exploit them to obtain various visual effects.

### Direct Color Mode

This trick is only applicable with PPU rendering turned off (OAM/Background = OFF).

In this mode, the PPU gets the palette index from the TH register as described above, so by writing to the PPU address space at addresses $3Fxx (where xx = 0x00 ... 0x1F) you can trick the PPU into showing the palette color with the specified index.
(In fact, you don't even have to do a read/write of the palette memory byte, just set the PPU address with register $2005 so that its low-order part is stored in the TH register).

This technique is demonstrated in the `Full palette demo` (by Blargg): https://wiki.nesdev.org/w/index.php/Full_palette_demo

There it is also stated that the speed of the NES CPU is not sufficient to simulate full bitmap graphics (1 CPU cycle corresponds to 3 PPU "pixels")

### Exploiting EXT Pins

The value from the EXT pins can be used as another color source. But since these pins are usually connected to GND you can only get a black color from them, which can be used to erase the screen with arbitrary patterns.

To do this, you need to program the PPU to Slave mode ($2000\[6\] = 0) when the H/V PPU counters are at the desired location on the screen.

This technique has not yet been confirmed experimentally and exists only as a hypothesis.
