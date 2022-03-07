# Sprite Comparison

The sprite comparison circuit compares all 64 sprites and selects the first 8 sprites that occur first on the current line (H). The fact that the PPU can only draw the first 8 sprites of a line is a well-known fact that has to be taken into account when programming NES. Usually programmers use sprite shuffling, but even this has the effect of "flickering" sprites.

The selected sprites are placed in additional memory OAM2, from where they then go to [OAM FIFO](fifo.md) for further processing.

The circuit includes:
- OAM index counter, to sample the next sprite for comparison
- OAM2 index counter, to save the comparison results
- Schematics for controlling the counters
- A comparator, which is essentially a small ALU and performs a signed subtraction operation (A - B)
- The comparison control circuit which implements the whole logic of sprite comparison operation

The circuits for controlling the counters are separated beforehand, maybe it makes sense to combine them into one circuit.

## OAM Index Counter

![oam_index_counter](/BreakingNESWiki/imgstore/ppu/oam_index_counter.jpg)

## OAM Index Counter Control

![oam_index_counter_control](/BreakingNESWiki/imgstore/ppu/oam_index_counter_control.jpg)

## Temp OAM Index Counter

![oam2_index_counter](/BreakingNESWiki/imgstore/ppu/oam2_index_counter.jpg)

![ppu_logisim_oam2_counter](/BreakingNESWiki/imgstore/ppu/ppu_logisim_oam2_counter.jpg)

## Counters Control

![oam_counters_control](/BreakingNESWiki/imgstore/ppu/oam_counters_control.jpg)

## H0'' Auxiliary Circuit

The `H0''` signal which is used in the counter control circuits does not come from the H-Outputs which are in the [H/V FSM](hv_fsm.md) circuit, but is derived by the circuit which is in between the connections to the left of the sprite logic.

This special `H0''` signal (but essentially a variation of the regular H0'' signal) is marked with an arrow on the transistor circuits.

![h0_dash_dash_tran](/BreakingNESWiki/imgstore/ppu/h0_dash_dash_tran.jpg)

## Comparator

![oam_cmpr](/BreakingNESWiki/imgstore/ppu/oam_cmpr.jpg)

## Comparison Control

![oam_eval_control](/BreakingNESWiki/imgstore/ppu/oam_eval_control.jpg)

## Logisim Circuit

![ppu_logisim_oam_eval](/BreakingNESWiki/imgstore/ppu/ppu_logisim_oam_eval.jpg)
