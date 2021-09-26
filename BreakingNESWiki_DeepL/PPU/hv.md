# H/V Counters

H/V counters count the number of pixels per line and the number of lines, respectively. H ticks from 0 to 340 (including), V ticks from 0 to 261 (including). The total visible part of the screen is 262 lines of 341 pixels each.

Technically the counters consist of 9 bits, so they can count from 0 to 0x1FF, but they never count completely and are limited to the maximum H and V values. To do this, the H/V FSM circuit periodically resets them.

## Counter stage

Examine the operation of a single counter stage (single bit) using the V-Counter as an example.

![HV_stage](/BreakingNESWiki/imgstore/HV_stage.jpg)

![hv_stage2](/BreakingNESWiki/imgstore/hv_stage2.jpg)

![hv_stage2_annotated](/BreakingNESWiki/imgstore/hv_stage2_annotated.jpg)

- `/carry_in`: input carry in inverse logic
- `/carry_out`: output carry in inverse logic
- `out`: output of one counter bit, in direct logic
- `VC` (or `HC` at H-Counter): the clear signal of the entire counter. This clearing method is used to control counter clearing from the H/V FSM circuit side.
- `RES`: general reset signal. This is the global reset signal of all sequential PPU circuits.
- `PCLK`: Pixel Clock

In the image the transistors that form the logic elements are highlighted.

The circuit is not very complicated, except for the unusual FF organization based on two 2-nor and two multiplexers that form the FF loop.

A nice scheme from Logisim:

![hv_stage_logisim](/BreakingNESWiki/imgstore/hv_stage_logisim.jpg)

## H/V counter design

TODO: redo, simplify a bit

Since the H-counter counts all the time, the input of the very first stage is wired to Vdd.
The V-Counter input is regulated by the H-decoder. when H=340, the V-Counter `/V_IN` input is set to 0 (`/carry_in` = 0), which gives the ability to increase its value by 1.
The output carry of each previous stage is wired to the input carry of the next, to form an inverted carry-chain.

## Why the carry logic is needed

The counters include such a small piece:

![CARRYH](/BreakingNESWiki/imgstore/CARRYH.jpg)

What is it for? Most likely to reduce the propagation delay of the carry chain.

## Simulation
