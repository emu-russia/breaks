# PPU Pinout

![ppu_pads](/BreakingNESWiki/imgstore/ppu_pads.jpg)

|Name|Direction|Description|
|---|---|---|
|R/W	|in PPU	|Read-notWrite. Used to read/write PPU registers. If R/W = 1 it reads, otherwise it writes. It is easy to remember: "Read(1), do not write".|
|D0-D7	|bidirectional	|The data bus for transferring register values. When /DBE = 1 the bus is disconnected (Z)|
|RS0-RS2	|in PPU	|Register Select. Sets the PPU register number (0-7)|
|/DBE	|in PPU	|Data Bus Enable. If /DBE = 0, then the D0-D7 bus is used to exchange values with the PPU registers, otherwise the bus is disconnected.|
|EXT0-EXT3	|bidirectional	|The bus is used to mix the color of the current pixel from another PPU (slave mode), or to output the current color to the outside (master mode). The direction of the bus is determined by the register bit $2002\[6\] (0: PPU slave mode, 1: PPU master mode) (_I apologize for using the old master/slave terms_)|
|CLK	|in PPU	|Main Clock|
|/INT	|from PPU	|PPU interrupt signal (VBlank)|
|ALE	|from PPU	|Address Latch Enable. If ALE=1, then the bus AD0-AD7 operates as an address bus (A0-A7), otherwise it operates as a data bus (D0-D7)|
|AD0-AD7	|ALE=1: from PPU (address), ALE=0: bidirectional (data)	|Multiplexed address/data bus. When ALE=1 the bus operates as an address bus, when ALE=0 the bus sends data to the PPU (patterns, attributes), or out from the PPU port (register $2007)|
|A8-A13	|from PPU (address)	|This bus carries the rest of the address lines.|
|/RD	|from PPU	|/RD=0: the PPU data bus (AD0-AD7) is used for reading (VRAM -> PPU)|
|/WR	|from PPU	|/WR=0: the PPU data bus (AD0-AD7) is used for writing (PPU -> VRAM)|
|/RES	|in PPU	|/RES=0: reset the PPU|
|VOUT	|from PPU	|Composite video signal|

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

<img src="/BreakingNESWiki/imgstore/20181128-101155.png" width="600px">

The R/W signal determines the direction of data exchange on the D0-D7 bus:
- R/W=0: Write. The data bus becomes input
- R/W=1: Read. The data bus becomes output

### D0-D7

<img src="/BreakingNESWiki/imgstore/20181128-101050.png" width="600px">

The D0-D7 data bus is used to exchange data between the CPU and the PPU registers.

The register index is selected by pins RS0-RS2.

### RS0-RS2

<img src="/BreakingNESWiki/imgstore/20181128-100949.png" width="600px">

RS0-RS2 signals select the PPU register index (0-7) to exchange data with the CPU.

### /DBE

<img src="/BreakingNESWiki/imgstore/20181128-100801.png" width="600px">

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

<img src="/BreakingNESWiki/imgstore/20181128-101334.png" width="600px">

The ALE (Address Latch Enable) signal is used to multiplex the AD0-AD7 bus:
- When ALE=1 the AD0-AD7 bus operates as the VRAM address bus (A0-A7)
- When ALE=0 the AD0-AD7 bus works as a VRAM data bus (D0-D7)

This trick was widespread in those days, to reduce the number of pins.

In modern chips, bus multiplexing is used less often because it requires additional clock cycles to move the bus from one state to another and the technological norms allow to separate the buses.

### AD0-AD7

<img src="/BreakingNESWiki/imgstore/20181128-101650.png" width="600px">

Bidirectional multiplexed data/address bus for data exchange with VRAM.

### A8-A13

<img src="/BreakingNESWiki/imgstore/20181128-101736.png" width="600px">

VRAM address bus.

Works only for output.

### /RD

<img src="/BreakingNESWiki/imgstore/20181128-101819.png" width="600px">

The /RD signal is complementary to the /WR signal (they cannot take the same values).

When /RD=0 the AD0-AD7 data bus is used to read VRAM data (input).

### /WR

<img src="/BreakingNESWiki/imgstore/20181128-101848.png" width="600px">

The /WR signal is complementary to the /RD signal (they cannot take the same values).

When /WR=0 the AD0-AD7 data bus is used to write VRAM data (output).

The /RD and /WR signals can be confused with the internal signals /RD\_internal and /WR\_internal, which are derived from the R/W input signal by the [RW decoder](regs.md) circuit.

## Interface with other PPUs

This interface is implemented by the EXT0-EXT3 inout pins.

<img src="/BreakingNESWiki/imgstore/20181128-100636.png" width="600px">

The developers have provided for the interaction of several PPU. The scheme of interaction is simple and looks as follows:
- Inside the PPU is a [multiplexer] (mux.md) that can optionally send a "picture" to both the screen or the external EXT pins
- The multiplexer can also receive a "picture" from the external EXT pins

The term "picture" refers to a set of abstract video data to explain the interaction between the PPUs.

So PPUs could be connected in a chain and each PPU could "mix" its part of the picture with the resulting "picture".

In practice this arrangement has not (to my knowledge) been used, probably because the PPU does not have a SYNC signal between several PPUs. Without such a signal it is difficult to synchronize data exchange via EXT pins, because it is not clear what to do now - to take new data or give them out.

## Control signals

### CLK

![PPU clk](/BreakingNESWiki/imgstore/clk.jpg)

(contact pad not shown)

The input CLK is split into two internal complementary signals: CLK and /CLK.

CLK is used exclusively in the phase generator of the PPU video path.

All other circuits are clocked by [Pixel Clock](pclk.md)

### /RES

![PPU resetpad](/BreakingNESWiki/imgstore/resetpad.jpg)

(contact pad not shown)

After the external /RES = 0 signal arrives, the latch is set so that the reset signal is not "lost".
The latch remains set until cleared by `RESCL` = 1.

The output value of the latch is fed to the register clearing circuit (the `RC` - Register Clear signal).

At power-up the `Reset FF` (marked with a yellow hexagon in the figure) takes an undefined value (x).

The circuit is fully asynchronous and independent of CLK.

### /INT

<img src="/BreakingNESWiki/imgstore/20181128-101916.png" width="600px">

The /INT output signal is used to signal the CPU about a VBlank interrupt.

In Famicom/NES the /INT signal is wired to the /NMI signal of the 6502 processor.

## VOUT

Output analog video signal.
