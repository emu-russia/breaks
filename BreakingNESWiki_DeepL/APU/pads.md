# APU Pinout

The study of any IC begins with the pinout.

![apu_pads](/BreakingNESWiki/imgstore/apu/apu_pads.jpg)

|Name|Number|Direction|Description|
|---|---|---|---|
|SND1|1|APU =>|DAC output of square channels (can be found under the name `AUX A`)|
|SND2|2|APU =>|DAC output for the remaining channels (triangle, noise, and DAC) (can be found as `AUX B')|
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

## SND1/2

Considered in the [DAC](dac.md) section.

## /RES

![pad_res](/BreakingNESWiki/imgstore/apu/pad_res.jpg)

From the external `/RES` signal you get the internal reset signal `RES`.

## A0-A15

![pad_a](/BreakingNESWiki/imgstore/apu/pad_a.jpg)

The value from the internal address bus is directly output to pins A0-A15 (without buffering). During reset (`RES` = 1) - pins A0-A15 are disabled (`z`).

## D0-D7

![pad_d](/BreakingNESWiki/imgstore/apu/pad_d.jpg)

- `RD` and WR` are two complementary signals
- When `RD` equals 1 pins D0-D7 act as input
- When `WR` is 1 pins D0-D7 act as output

The internal and external data buses are connected directly (without buffering).

## CLK, DBG, M2

Covered in the [6502 core](core.md) section.

## /IRQ

![pad_irq](/BreakingNESWiki/imgstore/apu/pad_irq.jpg)

The logic design of this contact is a bit redundant. The value of the /IRQ contact generates the value of the internal signal /IRQ (with the same name).

## /NMI

![pad_nmi](/BreakingNESWiki/imgstore/apu/pad_nmi.jpg)

The /NMI contact design is not different from the /IRQ contact design.

## R/W

![pad_rw](/BreakingNESWiki/imgstore/apu/pad_rw.jpg)

The output value of the R/W contact is derived from the internal R/W signal, and during reset R/W is disabled (when /RES contact = 0 and internal RES line = 1), that is, it has a Z (high-impedance) value.

A small tri-state logic controls the disconnection of the R/W pin.

Some of the push/pull inverters used to delay the R/W line are disabled. Apparently the designers adjusted the propagation delay to trigger the contact.
This same delay line also slows down the internal R/W signal a bit.

## Input/Output Ports

|/INx|OUTx|
|---|---|
|![pad_in](/BreakingNESWiki/imgstore/apu/pad_in.jpg)|![pad_out](/BreakingNESWiki/imgstore/apu/pad_out.jpg)|

The pin design is not different from the D0-D7 pin design, except that the analog of the `RD` signal is the internal reset signal (`RES`) and the analog of the `WR` signal is always connected to VCC (equal to 1, i.e. the pin always works as output).

For some reason, the I/O ports of the APU work to the input during reset. TBD: Find out why this is done.

The output value for contacts `/IN0-1` is the internal signals `/R4016` and `/R4017`.
The output value for the `OUT0-2` pins is obtained from the internal signals `OUT0-2` (with the same name). The schematic of the formation of these signals can be found in [6502 Core](core.md) section.
