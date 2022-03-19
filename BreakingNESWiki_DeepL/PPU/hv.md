# H/V Counters

![ppu_locator_hv](/BreakingNESWiki/imgstore/ppu/ppu_locator_hv.jpg)

H/V counters count the number of pixels per line and the number of lines, respectively. H ticks from 0 to 340 (including), V ticks from 0 to 261 (including). The total visible and invisible part of the screen is 262 lines of 341 pixels each.

Technically the counters consist of 9 bits, so they can count from 0 to 0x1FF, but they never count completely and are limited to the maximum H and V values. To do this, the H/V FSM circuit periodically resets them.

## Counter Stage

Examine the operation of a single counter stage (single bit) using the V-Counter as an example.

![HV_stage](/BreakingNESWiki/imgstore/ppu/HV_stage.jpg)

![hv_stage2](/BreakingNESWiki/imgstore/ppu/hv_stage2.jpg)

![hv_stage2_annotated](/BreakingNESWiki/imgstore/ppu/hv_stage2_annotated.jpg)

- `carry_in`: input carry
- `carry_out`: output carry
- `out`: output of single counter bit
- `/out`: output of single counter bit (inverted value). Used in carry optimization circuits.
- `VC` (or `HC` at H-Counter): the clear signal of the entire counter. This clearing method is used to control counter clearing from the H/V FSM circuit side.
- `RES`: general reset signal. This is the global reset signal of all sequential PPU circuits.
- `PCLK`: Pixel Clock

In the image the transistors that form the logic elements are highlighted.
The circuit is not very complicated, except for the unusual FF organization based on two 2-nor and two multiplexers that form the FF loop.

Logic:

![hv_stage_logisim](/BreakingNESWiki/imgstore/ppu/hv_stage_logisim.jpg)

The meaning is as follows:
- Virtually the current FF value can be represented as a multiplexer output controlled by PCLK
- In the state PCLK=0 the FF value is regenerated with the old value (taking into account the global reset `RES`). Also, this state engages the counting circuit, which is implemented on the Carry-multiplexer and static latch
- In the state PCLK=1 value FF updated with the new value from the counting circuit

Maybe there is actually some JK trigger hiding here, but I don't know about these JKs. There's a big article on Wiki about counters, if you're interested read it.

## H/V Counters Design

I didn't want to spam big pictures, but I guess I have to.

|H|V|
|---|---|
|![H_trans](/BreakingNESWiki/imgstore/ppu/H_trans.jpg)|![V_trans](/BreakingNESWiki/imgstore/ppu/V_trans.jpg)|

- HCounter always counts because the carry_in of bit 0 is always 1 (connected to Vdd)
- VCounter increments by 1 only when input `V_IN` is active
- The output carry of each previous bit is set to the input carry of the next bit to form the carry-chain
- Each counter includes additional transfer logic (below), for this reason I had to post large pictures of counters to see this logic

## Extra Carry Logic

Counters include a little piece like this:

|HCounter|VCounter|
|---|---|
|![CARRYH](/BreakingNESWiki/imgstore/ppu/CARRYH.jpg)|![CARRYV](/BreakingNESWiki/imgstore/ppu/CARRYV.jpg)|
|![CarryH_Logic](/BreakingNESWiki/imgstore/ppu/CarryH_Logic.jpg)|![CarryV_Logic](/BreakingNESWiki/imgstore/ppu/CarryV_Logic.jpg)|

The circuit for HCounter does not include an analog to V_IN because the input carry for H is always 1 and is not required for the NOR operation that this extra logic represents.

What's it for? Probably to reduce the propagation delay of the carry chain.

In simulation, you can do quite well without these "patches", the operation of the counters won't be any different.
