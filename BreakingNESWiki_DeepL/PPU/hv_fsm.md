# H/V Control Logic

The H/V logic is a finite state machine (FSM) that controls all other PPU parts. Schematically it is just a set of latches, like "this latch is active from 64th to 128th pixel", so the corresponding control line coming from this latch is also active.

## Outputting the H

H counter bits are used on other PPU components.

![h_counter_output](/BreakingNESWiki/imgstore/ppu/h_counter_output.jpg)

## HPos Logic

"Horizontal" logic, responsible for generating control lines depending on the horizontal position of the beam (H):

![hv_fporch](/BreakingNESWiki/imgstore/ppu/hv_fporch.jpg)

![hv_fsm_horz](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz.jpg)

## VPos Logic

![hv_fsm_vert](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert.jpg)

### H/V Counters Control

![hv_counters_control](/BreakingNESWiki/imgstore/ppu/hv_counters_control.jpg)

### EVEN/ODD Logic

![even_odd_tran](/BreakingNESWiki/imgstore/ppu/even_odd_tran.jpg) ![even_odd_flow1](/BreakingNESWiki/imgstore/ppu/even_odd_flow1.jpg) ![even_odd_flow2](/BreakingNESWiki/imgstore/ppu/even_odd_flow2.jpg)

The EVEN/ODD logic consists of two closed to each other pseudo latches controlled by two multiplexers. This results in a very clever "macro" latch.

TODO: The schematic should be analyzed again, because what the hell is this "macro-latch"... In addition, the scheme for PAL PPU is different from the NTSC version.
