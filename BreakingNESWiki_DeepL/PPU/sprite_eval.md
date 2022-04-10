# Sprite Comparison

![ppu_locator_sprite_eval](/BreakingNESWiki/imgstore/ppu/ppu_locator_sprite_eval.jpg)

The sprite comparison circuit compares all 64 sprites and selects the first 8 sprites that occur first on the current line (V). The fact that the PPU can only draw the first 8 sprites of a line is a well-known fact that has to be taken into account when programming NES. Usually programmers use sprite shuffling, but even this has the effect of "flickering" sprites.

The selected sprites are placed in additional memory OAM2, from where they then go to [OAM FIFO](fifo.md) for further processing.

The circuit includes:
- OAM index counter, to sample the next sprite for comparison
- OAM2 index counter, to save the comparison results
- Schematics for controlling the counters
- A comparator, which is essentially a small ALU and performs a signed subtraction operation (A - B)
- The comparison control circuit which implements the whole logic of sprite comparison operation

![OAM_Eval](/BreakingNESWiki/imgstore/ppu/OAM_Eval.png)

## Counters Bit

![OAM_CounterBit](/BreakingNESWiki/imgstore/ppu/OAM_CounterBit.png)

## OAM Index Counter

![oam_index_counter](/BreakingNESWiki/imgstore/ppu/oam_index_counter.jpg)

![OAM_MainCounter](/BreakingNESWiki/imgstore/ppu/OAM_MainCounter.png)

## Temp OAM Index Counter

![oam2_index_counter](/BreakingNESWiki/imgstore/ppu/oam2_index_counter.jpg)

![OAM_TempCounter](/BreakingNESWiki/imgstore/ppu/OAM_TempCounter.png)

## Counters Control

![oam_index_counter_control](/BreakingNESWiki/imgstore/ppu/oam_index_counter_control.jpg)

![oam_counters_control](/BreakingNESWiki/imgstore/ppu/oam_counters_control.jpg)

![OAM_CountersControl](/BreakingNESWiki/imgstore/ppu/OAM_CountersControl.png)

![OAM_SprOV_Flag](/BreakingNESWiki/imgstore/ppu/OAM_SprOV_Flag.png)

## OAM Address

![OAM_Address](/BreakingNESWiki/imgstore/ppu/OAM_Address.png)

## H0'' Auxiliary Circuit

The `H0''` signal which is used in the counter control circuits does not come from the H-Outputs which are in the [H/V FSM](hv_fsm.md) circuit, but is derived by the circuit which is in between the connections to the left of the sprite logic.

This special `H0''` signal (but essentially a variation of the regular H0'' signal) is marked with an arrow on the transistor circuits.

![h0_dash_dash_tran](/BreakingNESWiki/imgstore/ppu/h0_dash_dash_tran.jpg)

## Comparator

![oam_cmpr](/BreakingNESWiki/imgstore/ppu/oam_cmpr.jpg)

![OAM_CmpBitPair](/BreakingNESWiki/imgstore/ppu/OAM_CmpBitPair.png)

![OAM_Cmp](/BreakingNESWiki/imgstore/ppu/OAM_Cmp.png)

## Comparison Control

![oam_eval_control](/BreakingNESWiki/imgstore/ppu/oam_eval_control.jpg)

![OAM_EvalFSM](/BreakingNESWiki/imgstore/ppu/OAM_EvalFSM.png)

![PosedgeDFFE](/BreakingNESWiki/imgstore/ppu/PosedgeDFFE.png)
