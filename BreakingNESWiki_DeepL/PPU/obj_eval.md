# Sprite Comparison (Object Evaluation)

![ppu_locator_obj_eval](/BreakingNESWiki/imgstore/ppu/ppu_locator_obj_eval.jpg)

The sprite comparison circuit compares all 64 sprites and selects the first 8 sprites that occur first on the current line (V). The fact that the PPU can only draw the first 8 sprites of a line is a well-known fact that has to be taken into account when programming NES. Usually programmers use sprite shuffling, but even this has the effect of "flickering" sprites.

The selected sprites are placed in additional memory OAM2, from where they then go to [Obj FIFO](fifo.md) for further processing.

The circuit includes:
- OAM index counter, to sample the next sprite for comparison
- OAM2 index counter, to save the comparison results
- Schematics for controlling the counters
- A comparator, which performs a signed subtraction operation (A - B)
- The comparison control circuit which implements the whole logic of sprite comparison operation

![Obj_Eval](/BreakingNESWiki/imgstore/ppu/Obj_Eval.png)

Inputs:

|Signal/group|Description|
|---|---|
|V0-7|The V counter bits|
|O8/16|Object lines 8/16 (размер спрайта)|
|PPU FSM||
|BLNK|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|I/OAM2|"Init OAM2". Initialize an additional (temp) OAM|
|/VIS|"Not Visible". The invisible part of the signal (used in sprite logic)|
|OBJ_READ|Common sprite fetch event, shared by many modules.|
|/EVAL|"Sprite Evaluation in Progress"|
|RESCL|"Reset FF Clear" / "VBlank Clear". VBlank period end event.|
|#F/NT|0: "Fetch Name Table"|
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
|SPR_OV|Sprites on the current line are more than 8 or the main OAM counter is full, copying is stopped|
|OV0-3|Bit 0-3 of the V sprite value|
|PD/FIFO|Used to fill in the FIFO with safe values if the comparison results in a number of sprites less than 8|
|/SPR0_EV|0: Sprite "0" IS found on the current line|

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
|COPY_OVF|The Johnson counter used to copy sprites is overflowed (all bits are 0)|
|OVZ|The sprite being checked is on the current line|
|OMFG|"OAM Counter Mode4"|
|COPY_STEP|Perform Johnson counter step|
|DO_COPY|Start the sprite copying process|

## H0'' Auxiliary Circuit

The `H0''` signal which is used in the counter control circuits does not come from the H-Outputs which are in the [PPU FSM](fsm.md) circuit, but is derived by the circuit which is in between the connections to the left of the sprite logic.

This special `H0''` signal (but essentially a variation of the regular H0'' signal) is marked with an arrow on the transistor circuits.

![h0_dash_dash_tran](/BreakingNESWiki/imgstore/ppu/h0_dash_dash_tran.jpg)

## Counters Bit

![Eval_CounterBit](/BreakingNESWiki/imgstore/ppu/Eval_CounterBit.png)

A typical counter bit circuit is used, with one exception: it is possible to "block" the counting (`BlockCount`). 

This feature is used only for bits 0 and 1 of the main counter in order to implement the modulo +4 counting mode. But blocking the count for the lower bits causes the internal carry chain to stop working for them, so an external carry chain for bits 2-7 is added to the circuit and used in Mode4.

## Main OAM Address Counter

![eval_main_counter](/BreakingNESWiki/imgstore/ppu/eval_main_counter.jpg)

![Eval_MainCounter](/BreakingNESWiki/imgstore/ppu/Eval_MainCounter.png)

## Temp OAM Address Counter

![eval_temp_counter](/BreakingNESWiki/imgstore/ppu/eval_temp_counter.jpg)

![Eval_TempCounter](/BreakingNESWiki/imgstore/ppu/Eval_TempCounter.png)

## Counters Control

|Main counter control|Temp OAM counter control and sprite overflow|
|---|---|
|![eval_main_counter_control](/BreakingNESWiki/imgstore/ppu/eval_main_counter_control.jpg)|![eval_counters_control](/BreakingNESWiki/imgstore/ppu/eval_counters_control.jpg)|

![Eval_CountersControl](/BreakingNESWiki/imgstore/ppu/Eval_CountersControl.png)

![Eval_SprOV_Flag](/BreakingNESWiki/imgstore/ppu/Eval_SprOV_Flag.png)

Operating modes of OAM counters:

|OAM Counter|Size (bits)|Modulo|Read/Write OAM via $2003/$2004|Initialization|Comparison (search)|Comparison (copy)|Fetching sprites from Temp OAM to FIFO|
|---|---|---|---|---|---|---|---|
|OAM|8|+1 / +4|working, modulo +1|not working|working, modulo +4|working, modulo +1|not working|
|Temp OAM|5|+1|not working|working|not working|working|working|

## OAM Address

![eval_oam_address_tran](/BreakingNESWiki/imgstore/ppu/eval_oam_address_tran.jpg)

![Eval_OAM_Address](/BreakingNESWiki/imgstore/ppu/Eval_OAM_Address.png)

## Comparator

![eval_cmpr](/BreakingNESWiki/imgstore/ppu/eval_cmpr.jpg)

![Eval_CmpBitPair](/BreakingNESWiki/imgstore/ppu/Eval_CmpBitPair.png)

The even and odd bits of the comparator are combined into a single circuit, to compact the inverted carry chain. Between "duplets" the carry chain is kept in direct logic.

Since the circuit is essentially a subtractor, it is more appropriate to say "borrow" instead of "carry", but the phrase "borrow chain" is not commonly used, so "carry chain" is used.

![Eval_Cmp](/BreakingNESWiki/imgstore/ppu/Eval_Cmp.png)

The opening transistors for the input latches are next to the OAM Buffer:

![oam_buffer_readback](/BreakingNESWiki/imgstore/ppu/oam_buffer_readback.jpg)

## Comparison Control

![eval_fsm](/BreakingNESWiki/imgstore/ppu/eval_fsm.jpg)

![Eval_FSM](/BreakingNESWiki/imgstore/ppu/Eval_FSM.png)

The nor+mux+FF arrangement is actually a Posedge DFFE. And the `#EN` (enable) input is in inverse logic.

![PosedgeDFFE](/BreakingNESWiki/imgstore/ppu/PosedgeDFFE.png)

:warning: Note that this circuit uses "Other /PCLK" (`/PCLK2`) instead of the usual `/PCLK`, which is obtained locally.
Practice and simulations have shown that such "Other CLKs" are important for the correct operation of the circuit.
In this case, this signal means that places where `/PCLK2` applies are triggered slightly later than other places where regular `/PCLK` applies.

## PD/FIFO

This signal is needed when OBJ_READ is active. At other times it does not have any effect. The meaning of this signal is to prohibit loading sprite comparison artifact into FIFO, provided that the sprites are less than 8, or sprites for the current line were not found. This artifact appears because of the simplified circuit of copying sprites from OAM to OAM2, because the write signal is active even if the copying has not begun. This cell gets the last value from memory when comparing sprites. 

In other words, if PD/FIFO = 1, then loading the pattern from PD (H. INV) is allowed, 0 is not allowed.

## Big Capacitor ("BigCap")

The `DO_COPY` signal is connected to a large capacitor, one lining of which is made of a piece of polysilicon and the other is the chip substrate (ground). This capacitor is needed to slightly delay the edge of the `DO_COPY` signal.