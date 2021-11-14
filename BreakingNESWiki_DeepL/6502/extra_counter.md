# Extended Сycle Сounter

![6502_locator_extended_counter](/BreakingNESWiki/imgstore/6502_locator_extended_counter.jpg)

The 6502 has 3 cycle counters:
- The base counter, used for short instructions (Counts T0-T1 cycles)
- Extended counter (which we will talk about here) used for long instructions (Counts cycles T2-T5)
- Counter for very long instructions (Counts cycles T6-T7)

One cycle (T) refers to two consecutive half-cycles (PHI2->PHI1) of the processor.

## Transistor Circuit

![extended_cycle_counter_trans](/BreakingNESWiki/imgstore/extended_cycle_counter_trans.jpg)

The whole circuit is a shift register, with a control signal `T1` as its input. While the shift register is running, the value of T1 is shifted and goes to the output of `/T2`, then to `/T3` and so on. The /T2-/T5 outputs are in inverse logic.

The shift register is used as a counter for easy transfer of the current cycle (/T2-/T5) to the decoder input.

The register is reset by the `TRES2` command and is done after the instruction has been processed.

The circuit includes multiplexers on the `/ready` signal. This is done so that when the processor is not ready (ready=0) - shift register remains in the current state.

## Logic

![extended_cycle_counter_logic](/BreakingNESWiki/imgstore/extended_cycle_counter_logic.jpg)
