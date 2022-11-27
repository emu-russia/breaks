# PPU Pinout

The study of any IC begins with the pinout.

|Our wiki|Official designations|
|---|---|
|![ppu_pads](/BreakingNESWiki/imgstore/ppu/ppu_pads.jpg)|![ppu_pinout_orig](/BreakingNESWiki/imgstore/ppu/ppu_pinout_orig.png)|

|Name|Number|Direction|Description|
|---|---|---|---|
|R/W	|1|=> PPU	|Read-notWrite. Used to read/write PPU registers. If R/W = 1 it reads, otherwise it writes. It is easy to remember: "Read(1), do not write".|
|D0-D7	|2-9|PPU <=>	|The data bus for transferring register values. When /DBE = 1 the bus is disconnected (Z)|
|RS0-RS2|10-12|=> PPU	|Register Select. Sets the PPU register number (0-7)|
|/DBE	|13|=> PPU	|Data Bus Enable. If /DBE = 0, then the D0-D7 bus is used to exchange values with the PPU registers, otherwise the bus is disconnected.|
|EXT0-EXT3|14-17|PPU <=>	|The bus is used to mix the color of the current pixel from another PPU (slave mode), or to output the current color to the outside (master mode). The direction of the bus is determined by the register bit $2000\[6\] (0: PPU slave mode, 1: PPU master mode) (_I apologize for using the old master/slave terms_)|
|CLK	|18|=> PPU	|Main Clock|
|/INT	|19|PPU =>	|PPU interrupt signal (VBlank)|
|ALE	|39|PPU =>	|Address Latch Enable. If ALE=1, then the bus AD0-AD7 operates as an address bus (A0-A7), otherwise it operates as a data bus (D0-D7)|
|AD0-AD7	|38-31|ALE=1: from PPU (address), ALE=0: bidirectional (data)	|Multiplexed address/data bus. When ALE=1 the bus operates as an address bus, when ALE=0 the bus sends data to the PPU (patterns, attributes), or out from the PPU port (register $2007)|
|A8-A13	|30-25|PPU => (address)	|This bus carries the rest of the address lines.|
|/RD	|24|PPU =>	|/RD=0: the PPU data bus (AD0-AD7) is used for reading (VRAM -> PPU)|
|/WR	|23|PPU =>	|/WR=0: the PPU data bus (AD0-AD7) is used for writing (PPU -> VRAM)|
|/RES	|22|=> PPU	|/RES=0: reset the PPU|
|VOUT	|21|PPU =>	|Composite video signal|

The contacts can be conditionally divided into the following groups:
- Interface with CPU
- Interface with VRAM
- Interface with other PPUs
- Control signals
- VOUT

## Interface with CPU

The interface with the CPU is used to access the registers of the PPU. This group of pins includes:
- R/W
- D0-D7
- RS0-RS2
- /DBE

### R/W

<img src="/BreakingNESWiki/imgstore/ppu/pad_rw.jpg" width="600px">

The R/W signal determines the direction of data exchange on the D0-D7 bus:
- R/W=0: Write. The data bus becomes input
- R/W=1: Read. The data bus becomes output

### D0-D7

<img src="/BreakingNESWiki/imgstore/ppu/pad_d.jpg" width="600px">

The D0-D7 data bus is used to exchange data between the CPU and the PPU registers.

The register index is selected by pins RS0-RS2.

The internal signals `/RD` and `/WR`, which are used in pins D0-D7, are obtained by the [RW Decoder](regs.md) circuit.

### RS0-RS2

<img src="/BreakingNESWiki/imgstore/ppu/pad_rs.jpg" width="600px">

RS0-RS2 signals select the PPU register index (0-7) to exchange data with the CPU.

### /DBE

<img src="/BreakingNESWiki/imgstore/ppu/pad_dbe.jpg" width="600px">

The contact prohibits exchange on the D0-D7 bus, i.e. completely disables the interface with the CPU.

- /DBE=0: Interface with CPU enabled
- /DBE=1: Interface with CPU disabled

## Interface with VRAM

More than half of the PPU logic is dedicated to sampling, storing and outputting (as a video signal) data from VRAM. This group of pins includes:
- ALE
- AD0-AD7
- A8-A13
- /RD
- /WR

### ALE

<img src="/BreakingNESWiki/imgstore/ppu/pad_ale.jpg" width="600px">

The ALE (Address Latch Enable) signal is used to multiplex the AD0-AD7 bus:
- When ALE=1 the AD0-AD7 bus operates as the VRAM address bus (A0-A7)
- When ALE=0 the AD0-AD7 bus works as a VRAM data bus (D0-D7)

This trick was widespread in those days, to reduce the number of pins.

In modern chips, bus multiplexing is used less often because it requires additional clock cycles to move the bus from one state to another and the technological norms allow to separate the buses.

### AD0-AD7

<img src="/BreakingNESWiki/imgstore/ppu/pad_ad.jpg" width="600px">

Bidirectional multiplexed data/address bus for data exchange with VRAM.

The last bus value is stored on the input DLatch. If no one has updated the bus value during the read cycle from outside, or if it has remained disconnected, the `PD` will take the last set value of the low-order part of the address. Because of the dynamic nature of the latch (the value is stored on the FET gate) - this behavior can have unpredictable effects.

### A8-A13

<img src="/BreakingNESWiki/imgstore/ppu/pad_a.jpg" width="600px">

VRAM address bus.

Works only for output.

### /RD

<img src="/BreakingNESWiki/imgstore/ppu/pad_rd.jpg" width="600px">

The /RD signal is complementary to the /WR signal (they cannot both be 0, but they can both be 1 when the VRAM interface is not in use).

When /RD=0 the AD0-AD7 data bus is used to read VRAM data (input).

The value of the /RD pin comes from the internal `RD` signal that comes out of [VRAM controller](vram_ctrl.md).

### /WR

<img src="/BreakingNESWiki/imgstore/ppu/pad_wr.jpg" width="600px">

The /WR signal is complementary to the /RD signal (they cannot both be 0, but they can both be 1 when the VRAM interface is not in use).

When /WR=0 the AD0-AD7 data bus is used to write VRAM data (output).

The value of the /WR pin comes from the internal `WR` signal that comes out of [VRAM controller](vram_ctrl.md).

## Interface with other PPUs

This interface is implemented by the EXT0-EXT3 inout pins.

<img src="/BreakingNESWiki/imgstore/ppu/pad_ext.jpg" width="600px">

Developers have made provisions for the interaction of several PPUs. The scheme of interaction is simple and looks as follows:
- Inside the PPU is a [multiplexer](mux.md) that can optionally send a "picture" to both the screen or the external EXT pins
- The multiplexer can also receive a "picture" from the external EXT pins

The term "picture" refers to a set of abstract video data to explain the interaction between the PPUs.

So PPUs could be connected in a chain and each PPU could "mix" its part of the picture with the resulting "picture".

The synchronization between PPUs is done simply by the sequence of EXT pins output and receive data (see multiplexer). The patent suggests that, for additional synchronization of the PPUs, their /RES pins should be combined so that all H/V registers and counters are reset simultaneously.

![ext_pads](/BreakingNESWiki/imgstore/ppu/ext_pads.png)

## Control signals

### CLK

Contact pad:

![pad_clk](/BreakingNESWiki/imgstore/ppu/pad_clk.jpg)

Resembles the relaxation oscillator: https://en.wikipedia.org/wiki/Schmitt_trigger#Use_as_an_oscillator

CLK distribution logic:

![PPU clk](/BreakingNESWiki/imgstore/ppu/clk.jpg)

The input CLK is split into two internal complementary signals: CLK and /CLK.

CLK is used exclusively in the phase generator of the PPU video path.

All other circuits are clocked by [Pixel Clock](pclk.md)

### /RES

![pad_res](/BreakingNESWiki/imgstore/ppu/pad_res.jpg)

(contact pad not shown)

After the external /RES = 0 signal arrives, the `Reset FF` is set so that the reset signal is not "lost".
The `Reset FF` remains set until cleared by `RESCL` = 1.

The output value of the `Reset FF` is fed to the register clearing circuit (the `RC` - Register Clear signal).

At power-up the `Reset FF` (marked with a yellow hexagon in the figure) takes an undefined value (x).

The circuit is fully asynchronous and independent of CLK.

### /INT

<img src="/BreakingNESWiki/imgstore/ppu/pad_int.jpg" width="600px">

The /INT output signal is used to signal the CPU about a VBlank interrupt.

In Famicom/NES the /INT signal is wired to the /NMI signal of the 6502 processor.

## VOUT

Output analog [video signal](tv.md).

## Logic

Logic of all terminals in single picture:

![pads_all](/BreakingNESWiki/imgstore/ppu/pads_all.jpg)
