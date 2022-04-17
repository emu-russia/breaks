# Sprite Comparison

![ppu_locator_sprite_eval](/BreakingNESWiki/imgstore/ppu/ppu_locator_sprite_eval.jpg)

The sprite comparison circuit compares all 64 sprites and selects the first 8 sprites that occur first on the current line (V). The fact that the PPU can only draw the first 8 sprites of a line is a well-known fact that has to be taken into account when programming NES. Usually programmers use sprite shuffling, but even this has the effect of "flickering" sprites.

The selected sprites are placed in additional memory OAM2, from where they then go to [OAM FIFO](fifo.md) for further processing.

The circuit includes:
- OAM index counter, to sample the next sprite for comparison
- OAM2 index counter, to save the comparison results
- Schematics for controlling the counters
- A comparator, which performs a signed subtraction operation (A - B)
- The comparison control circuit which implements the whole logic of sprite comparison operation

![OAM_Eval](/BreakingNESWiki/imgstore/ppu/OAM_Eval.png)

Inputs:

|Signal/group|Description|
|---|---|
|V0-7|The V counter bits|
|O8/16|Object lines 8/16 (размер спрайта)|
|PPU FSM||
|BLNK|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|I/OAM2|"Init OAM2". Initialize an additional (temp) OAM|
|/VIS|"Not Visible". The invisible part of the signal (used in sprite logic)|
|PAR/O|"PAR for Object". Selecting a tile for an object (sprite)|
|EVAL|"Sprite Evaluation in Progress"|
|RESCL|"Reset FF Clear" / "VBlank Clear". VBlank period end event.|
|F/NT|"Fetch Name Table"|
|S/EV|"Start Sprite Evaluation"|
|Delayed H||
|H0'|H0 signal delayed by one DLatch|
|H0''|H0 signal delayed by two DLatch|
|/H2'|H2 signal delayed by one DLatch (in inverse logic)|
|CPU I/F||
|/DBE|"Data Bus Enable", enable CPU interface|
|/R2|Read $2002|
|/W3|Write $2003|
|OAM||
|OFETCH|"OAM Fetch"|
|OB0-7|OB output value|

Outputs:

|Signal|Description|
|---|---|
|/OAM0-7|OAM Address|
|OAM8|Selects an additional (temp) OAM for addressing|
|OAMCTR2|OAM Buffer Control|
|SPR_OV|TBD.|
|OV0-3|Bit 0-3 of the V sprite value|
|0/FIFO|To zero the output of the H. Inv circuit|
|I2SEV|TBD.|

Intermediate signals:

|Signal|Description|
|---|---|
|OMSTEP|Increase the main OAM counter (+1 or +4 determined by OMFG)|
|OMOUT|Keep the counter value of the main OAM|
|W3' (W3_Enable)|Write $2003 command|
|OMV|Main OAM counter overflow|
|OAM0-7|Main OAM counter outputs|
|OSTEP|Increment the Temp OAM counter|
|ORES|Reset Temp OAM counter|
|TMV|Temp OAM counter overflow|
|OAMTemp0-4|Temp OAM counter outputs|
|SPR_OV_Reg|$2002\[5\] FF value|
|M4_OVZ|Intermediate signal for the OVZ signal derivation|
|OVZ|TBD.|
|OMFG|"OAM Counter Mode4"|

## H0'' Auxiliary Circuit

The `H0''` signal which is used in the counter control circuits does not come from the H-Outputs which are in the [H/V FSM](hv_fsm.md) circuit, but is derived by the circuit which is in between the connections to the left of the sprite logic.

This special `H0''` signal (but essentially a variation of the regular H0'' signal) is marked with an arrow on the transistor circuits.

![h0_dash_dash_tran](/BreakingNESWiki/imgstore/ppu/h0_dash_dash_tran.jpg)

## Counters Bit

![OAM_CounterBit](/BreakingNESWiki/imgstore/ppu/OAM_CounterBit.png)

A typical counter bit circuit is used, with one exception: it is possible to "block" the counting (`BlockCount`). 

This feature is used only for bits 0 and 1 of the main counter in order to implement the modulo +4 counting mode. But blocking the count for the lower bits causes the internal carry chain to stop working for them, so an external carry chain for bits 2-7 is added to the circuit and used in Mode4.

## Main OAM Index Counter

![oam_index_counter](/BreakingNESWiki/imgstore/ppu/oam_index_counter.jpg)

![OAM_MainCounter](/BreakingNESWiki/imgstore/ppu/OAM_MainCounter.png)

## Temp OAM Index Counter

![oam2_index_counter](/BreakingNESWiki/imgstore/ppu/oam2_index_counter.jpg)

![OAM_TempCounter](/BreakingNESWiki/imgstore/ppu/OAM_TempCounter.png)

## Counters Control

|Main counter control|Temp OAM counter control and sprite overflow|
|---|---|
|![oam_index_counter_control](/BreakingNESWiki/imgstore/ppu/oam_index_counter_control.jpg)|![oam_counters_control](/BreakingNESWiki/imgstore/ppu/oam_counters_control.jpg)|

![OAM_CountersControl](/BreakingNESWiki/imgstore/ppu/OAM_CountersControl.png)

![OAM_SprOV_Flag](/BreakingNESWiki/imgstore/ppu/OAM_SprOV_Flag.png)

## OAM Address

![oam_address_tran](/BreakingNESWiki/imgstore/ppu/oam_address_tran.jpg)

![OAM_Address](/BreakingNESWiki/imgstore/ppu/OAM_Address.png)

## Comparator

![oam_cmpr](/BreakingNESWiki/imgstore/ppu/oam_cmpr.jpg)

![OAM_CmpBitPair](/BreakingNESWiki/imgstore/ppu/OAM_CmpBitPair.png)

The even and odd bits of the comparator are combined into a single circuit, to compact the inverted carry chain. Between "duplets" the carry chain is kept in direct logic.

![OAM_Cmp](/BreakingNESWiki/imgstore/ppu/OAM_Cmp.png)

The opening transistors for the input latches are next to the OAM Buffer:

![oam_buffer_readback](/BreakingNESWiki/imgstore/ppu/oam_buffer_readback.jpg)

## Comparison Control

![oam_eval_control](/BreakingNESWiki/imgstore/ppu/oam_eval_control.jpg)

![OAM_EvalFSM](/BreakingNESWiki/imgstore/ppu/OAM_EvalFSM.png)

The nor+mux+FF arrangement is actually a Posedge DFFE. And the `#EN` (enable) input is in inverse logic.

![PosedgeDFFE](/BreakingNESWiki/imgstore/ppu/PosedgeDFFE.png)
