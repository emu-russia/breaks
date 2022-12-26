# APU Pinout

The study of any IC begins with the pinout.

|Our wiki|Official designations|
|---|---|
|![apu_pads](/BreakingNESWiki/imgstore/apu/apu_pads.jpg)|![apu_pinout_orig](/BreakingNESWiki/imgstore/apu/apu_pinout_orig.png)|

|Name|Number|Direction|Description|
|---|---|---|---|
|AUX A|1|APU =>|DAC output of square channels|
|AUX B|2|APU =>|DAC output for the remaining channels (triangle, noise, and DPCM)|
|/RES|3|APU =>|Reset signal|
|A0-A15|4-19|APU =>|Address bus|
|GND|20| |Ground|
|D0-D7|28-21|APU <=>|Data bus|
|CLK|29|=> APU|Master clock|
|DBG|30|=> APU|Debug mode (DBG=1: Enable debug registers, DBG=0: Disable debug registers)|
|M2|31|APU =>|Modified PHI2 6502 core output|
|/IRQ|32|=> APU|Maskable interrupt signal|
|/NMI|33|=> APU|Non-maskable interrupt signal|
|R/W|34|APU =>|Data bus direction (R/W=1: read, R/W=0: write)|
|/IN1|35|APU =>|Read I/O port associated with register $4017|
|/IN0|36|APU =>|Read I/O port associated with register $4016|
|OUT2|37|APU =>|Write to the I/O port associated with register bit $4016\[2\]|
|OUT1|38|APU =>|Write to the I/O port associated with register bit $4016\[1\]|
|OUT0|39|APU =>|Write to the I/O port associated with register bit $4016\[0\]|
|VCC|40| |Power +5V|

## AUX A/B

Considered in the [DAC](dac.md) section.

## /RES

![pad_res](/BreakingNESWiki/imgstore/apu/pad_res.jpg)

From the external `/RES` signal you get the internal reset signal `RES`.

## A0-A15

![pad_a](/BreakingNESWiki/imgstore/apu/pad_a.jpg)

The value from the internal address bus is directly output to pins A0-A15 (without buffering). During reset (`RES` = 1) - pins A0-A15 are disabled (`z`).

## D0-D7

![pad_d](/BreakingNESWiki/imgstore/apu/pad_d.jpg)

- `RD` and `WR` are two complementary signals
- When `RD` equals 1 pins D0-D7 act as input
- When `WR` is 1 pins D0-D7 act as output

The internal and external data buses are connected directly (without buffering).

## CLK

![pad_clk](/BreakingNESWiki/imgstore/apu/pad_clk.jpg)

## M2

![pad_m2](/BreakingNESWiki/imgstore/apu/pad_m2.jpg)

Circuit for obtaining the `NotDBG_RES` signal:

![notdbg_res_tran](/BreakingNESWiki/imgstore/apu/notdbg_res_tran.jpg)

For some reason the circuit contains a disabled "comb" of transistors, which is a chain of inverters of the internal `RES` signal.

In debug mode (when DBG=1) - the external signal M2 is not touched during reset. In regular mode (for Retail consoles) - during reset the external signal M2 is in `z` state (Open-drain).

## DBG

![pad_dbg](/BreakingNESWiki/imgstore/apu/pad_dbg.jpg)

## /IRQ

![pad_irq](/BreakingNESWiki/imgstore/apu/pad_irq.jpg)

The logic design of this contact is a bit redundant. The value of the /IRQ input terminal generates the value of the internal signal /IRQ (with the same name).

## /NMI

![pad_nmi](/BreakingNESWiki/imgstore/apu/pad_nmi.jpg)

The /NMI contact design is not different from the /IRQ terminal design.

## R/W

![pad_rw](/BreakingNESWiki/imgstore/apu/pad_rw.jpg)

The output value of the R/W contact is derived from the internal `RW` signal, and during reset R/W is disabled (when /RES contact = 0 and internal RES line = 1), that is, it has a Z (high-impedance) value.

A small tri-state logic controls the disconnection of the R/W pin.

Some of the push/pull inverters used to delay the R/W line are disabled. Apparently the designers adjusted the propagation delay to trigger the signal.
This same delay line also slows down the internal R/W signal a bit.

## Input/Output Ports

|/INx|OUTx|
|---|---|
|![pad_in](/BreakingNESWiki/imgstore/apu/pad_in.jpg)|![pad_out](/BreakingNESWiki/imgstore/apu/pad_out.jpg)|

The design is not different from the D0-D7 terminals design, except that the analog of the `RD` signal is the internal reset signal (`RES`) and the analog of the `WR` signal is always connected to VCC (equal to 1, i.e. the pin always works as output).

During reset (RES = 1) the In/Out terminals are disconnected. During reset the terminal circuit operates similarly to the D0-D7 terminal circuit, with RD = WR = 1, and this signal value disconnects the terminal (`z`).

- The output value for pins `OUT0-2` is derived from the internal signals `OUT0-2` (with the same name).
- The output value for pins `/IN0-1` is the internal signals `/R4016` and `/R4017` from the register selector.

Circuit for producing OUTx signals:

![out_tran](/BreakingNESWiki/imgstore/apu/out_tran.jpg)

![OUT_Ports](/BreakingNESWiki/imgstore/apu/OUT_Ports.jpg)

![IORegBit](/BreakingNESWiki/imgstore/apu/IORegBit.jpg)

## Pads Schematics

Truly unidirectional terminals:

![Pads1](/BreakingNESWiki/imgstore/apu/Pads1.jpg)

Terminals using BIDIR circuit:

![Pads2](/BreakingNESWiki/imgstore/apu/Pads2.jpg)

As mentioned above, only the data bus uses all the features of the bidirectional terminal. The other pads based on the BIDIR circuit are redundant.

BIDIR pad schematic:

![BIDIR_Pad](/BreakingNESWiki/imgstore/apu/BIDIR_Pad.jpg)
