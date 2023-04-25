# Waves

This section contains signal timings for different PPU units. Circuit engineers like to look thoughtfully at these.

The sources of all the tests that were used to make the diagrams are in the folder `/HDL/Framework/Icarus`.

## PCLK

## H/V Counters

## H/V Decoders

## FSM Delayed H Outputs

## FSM State Signals

The states within the scanline:

![fsm_scan](/BreakingNESWiki/imgstore/ppu/waves/fsm_scan.png)

States inside VBlank:

![fsm_vblank](/BreakingNESWiki/imgstore/ppu/waves/fsm_vblank.png)

Note that the figure with the scalines is scaled up (as seen by the change in the pixel counter H), compared to the scale in the VBlank figure (as seen by the change in the line counter V).

## OAM Evaluate

## OAM Comparator

## SpriteH Signals

## PAR Control

## OAM FIFO Lane

## VRAM Controller

## Video Output

Demonstration of the phase shifter output, with phases arranged according to the colors of the PPU palette (1 "pixel" is highlighted by a frame):

![phase_shifter](/BreakingNESWiki/imgstore/ppu/waves/phase_shifter.png)

![phase_shifter2](/BreakingNESWiki/imgstore/ppu/waves/phase_shifter2.png)
