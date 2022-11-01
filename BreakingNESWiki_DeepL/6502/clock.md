# Clock Generator

The 6502 includes two clock reference circuits: an external and an internal one.

The processor inputs one clock signal, `PHI0`, and outputs two clock signals, `PHI1` and `PHI2`.

This principle is based on the fact that each clock cycle of the processor consists of two "modes" (or "states"): write mode and read mode.

During write mode the `PHI1` signal is high. During this time, external devices can use the address set on the external address bus of the processor.

During read mode the signal `PHI2` is high. During this time external devices can write data to the processor's data bus so that the processor can use it for its own purposes.

The signals `PHI1` and `PHI2` are called half-cycles and are derived from the original clock signal `PHI0` as follows:
- When `PHI0` is low - the processor is in write mode and the `PHI1` signal is high
- When `PHI0` is high - the processor is in read mode and the `PHI2` signal is also high

|PHI0|PHI1|PHI2|
|---|---|---|
|0|1|0|
|1|0|1|

## Internal Clock

![clock_internal](/BreakingNESWiki/imgstore/6502/clock_internal.jpg)

The circuit is quite complicated, because it is not quite "digital". The numerous transistors that act as inverters slightly delay the PHI0 signal, so the PHI1 and PHI2 signals going inside the processor are a bit "laggy". Here is the logical representation of the circuit:

![clock_internal_logic](/BreakingNESWiki/imgstore/6502/clock_internal_logic.jpg)

Logical analysis:

![clock_internal_logic_zero](/BreakingNESWiki/imgstore/6502/clock_internal_logic_zero.jpg)

![clock_internal_logic_one](/BreakingNESWiki/imgstore/6502/clock_internal_logic_one.jpg)

The layout of the clock signals should be about the following:
- PHI1/PHI2 are slightly lagging relative to PHI0
- The lower level of PHI1/PHI2 is slightly longer than the upper level, so that both signals are guaranteed not to have a high level

![4672299](/BreakingNESWiki/imgstore/6502/4672299.png)

The simulation in Altera Quartus shows "lag", but does not show the elongated lower level (it is hand-drawn in the picture above).

BigEd from the 6502.org forum suggested that he ran a simulation on the 6502 FPGA netlist and got the following sweeps:

![cclk-rising](/BreakingNESWiki/imgstore/6502/cclk-rising.png)

![cclk-falling](/BreakingNESWiki/imgstore/6502/cclk-falling.png)

The signal designations are as follows: clk0 = PHI0, cp1 = PHI1, cclk = PHI2 (according to the netlist with Visual6502)

The schematic on which his simulation was based corresponds to the one in Balasz's documentation:

![clock_balazs](/BreakingNESWiki/imgstore/6502/clock_balazs.png)

http://forum.6502.org/viewtopic.php?f=8&t=2208&start=195

It turns out that because of the asymmetrical inverter stage the rising edge is delayed, so the lower level is as if "delayed".

The official documentation gives the following diagram:

![clock_timing_datasheet](/BreakingNESWiki/imgstore/6502/clock_timing_datasheet.jpg)

Optimized schematics:

![8_clock_internal](/BreakingNESWiki/imgstore/6502/ttlworks/8_clock_internal.png)

## External Clock

![clock_external](/BreakingNESWiki/imgstore/6502/clock_external.jpg)

The PHI1/PHI2 reference signals are also output to the outside for consumers.

The logic circuit of the external wiring of the clock signals does not differ from the internal wiring circuit, except that the outputs of PHI1/PHI2 go to the same contacts through the "comb" of powerful transistors.

## Why PHI

In the official 6502 datasheet the half-cycles are called "phases", respectively the name of these signals is Φ1 and Φ2. For unification we use the designations PHI1 and PHI2.
