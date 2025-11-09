# PPU

This section is simply a compilation of all subsections to make it easier to use in neural networks for their fine-tuning.

TODO: Duplicate all image in ASCII art so that they are understood by LLMs which can't analyse pictures.

# PPU Contents

- [Overview](#ppu-overview)
- [Pinout](#ppu-pinout)
- [Pixel Clock](#pixel-clock-pclk)
- [Control Registers](#ppu-registers)
- [H/V Counters](#hv-counters)
- [H/V Decoder](#hv-decoder)
- [PPU FSM](#ppu-fsm)
- [Color RAM](#color-ram)
- [NTSC Video Signal](#ntsc-video)
- [Video Signal Generator](#video-signal-generator)
- [OAM Evaluation](#sprite-comparison-oam-evaluation)
- [Multiplexer](#multiplexer)
- [Object Attribute Memory (OAM)](#oam)
- [OAM FIFO](#oam-fifo)
- [Data Fetcher](#data-reader)
  - [Scroll Registers](#scroll-registers)
  - [Picture Address Register](#picture-address-register)
  - [Background Color](#background-color-bg-col)
- [VRAM Controller](#vram-controller)
- [Interconnections](#wiring)
- [PAL PPU Differences](#pal-ppu)
- [RGB PPU Differences](#rgb-ppu)
- [UMC 6538 Differences](#umc-6538)

Appendix:

- [Visual 2C02 Signal Mapping](#visual-2c02-signal-mapping)
- [Waves](#waves)
- [Synchronous analysis](#synchronous-analysis)
- [PPU on YouTube](#ppu-on-youtube)

# PPU Overview

PPU (Picture Processing Unit) - a specialized IC for generating a video signal.

Sample picture that the PPU can produce:

<img src="/BreakingNESWiki/imgstore/ppu/battletoads.jpg" width="400px">

Revisions of PPU chips (preliminary synopsis table, information will be updated):

|Revision|Description|
|---|---|
|2C02G|Used in the Famicom and the American version of the NES. It generates an NTSC signal.|
|2C02H| |
|2C03|RGB-versions for arcade machines based on NES (PlayChoiсe-10, Vs. System)|
|2C03B| |
|2C03C| |
|2C04-0001| |
|2C04-0002| |
|2C04-0003| |
|2C04-0004| |
|2C05-01| |
|2C05-02| |
|2C05-03| |
|2C05-04| |
|2C05-99|Famicom Titler|
|2C07-0|PAL version of the PPU for the European NES.|

Probably exist (but no one has seen them):
- 2C01: Debug version of NTSC PPU (?)
- 2C06: Debug version of PAL PPU (?)

## Architecture

Main components of PPU:

![PPU_preview](/BreakingNESWiki/imgstore/ppu/PPU_preview.jpg)

- VIDEO OUT: contains NTSC signal generation circuitry and a DAC to convert it to analog form. That is, the PPU is essentially a semi-analog chip, since the VOUT pin outputs a ready-to-use analog signal (composite video).
- Next to the VOUT circuit is the control unit, which, based on the two counters H and V, generates a bunch of control signals, for the other components.
- Palette. It contains 16 colors of the background and 16 colors of the sprites. The index in the palette is used to load into the COLOR BUFFER the color of the pixel that will be displayed on the screen.
- Multiplexer (MUX). Selects what will be displayed: a background pixel or a sprite pixel, based on their priority. It is also possible to mix in a color from the external EXT pins.
- Registers. The total address space of the PPU allows to address 8 internal registers. The developers are very clever how registers are organized and writing to the same address can do two different things.
- Sprite memory (OAM). Contains 64 sprite data as well as extra space to store the 8 current sprites selected.
- Sprite Logic. Based on the V-counter, it selects 8 sprites of the current row, which are placed in additional OAM memory during the comparison process.
- Sprite FIFO (OAM FIFO). Contains a circuit that activates the output of the 8 selected sprites at the right time, as well as a circuit to control their priority.
- Address bus control circuitry. Controls the VRAM addressing.
- Data fetcher circuit (DATA READER). Circuit for fetching source data from VRAM: tiles and attributes. Includes a PAR address generator and a circuit for producing a background color.

![PPU](/BreakingNESWiki/imgstore/ppu/PPU.jpg)

## PPU Buses

The PPU contains the following internal data buses:

|Bus name|Abbreviation|Bus master|Users|
|---|---|---|---|
|CPU Data Bus|DB|PPU Regs|PatGen, OAM Ctr, OAM Buffer, Ctr Regs, Color Buffer, Read Buffer, Strike Test, Interrupt Ctr|
|PPU Data Bus|PD|NT RAM, CHR ROM, $2007|PatGen, BGCOL, H. INV|
|Object Bus|OB|OAM Buffer|PatGen, Obj FIFO, OAM Eval|

:warning: For correct simulation and implementation of the PPU on Verilog the DB bus capacity is important. A value placed on the bus at the CPU end while writing to the PPU registers can be used by the internal PPU circuits for which it is intended even after the CPU interface has finished its work (/DBE = 1). So the value on the DB bus still "hangs around" for a while and then is used by the PPU circuits. This is especially true for registers $2003 and $2007. It is recommended to use Transparent Latch or Bus Keeper if you are going to implement PPU circuits on HDL.

The PD (PPU Data) bus is less prone to floating problems because it is combined (multiplexed) with the PA (PPU Address) bus.

## Note on Transistor Circuits

The transistor circuits for each component are chopped up into component parts so that they don't take up too much space.

To keep you from getting lost, each section includes a special "locator" at the beginning that marks the approximate location of the component being studied.

An example of a locator:

![ppu_locator_rails_left](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_left.jpg)

## Note on Logic Circuits

The logic circuits are mostly made in the Logisim program. The following element is used to denote DLatch:

|DLatch (transistor circuit)|DLatch (logic equivalent)|
|---|---|
|![dlatch_tran](/BreakingNESWiki/imgstore/dlatch_tran.jpg)|![dlatch_logic](/BreakingNESWiki/imgstore/dlatch_logic.jpg)|

For convenience, the logical variant of DLatch has two outputs (`out` and `/out`), since the current value of DLatch (out) is often used as an input of a NOR operation.

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

The internal signals `/RD` and `/WR`, which are used in pins D0-D7, are obtained by the [RW Decoder](#ppu-registers) circuit.

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

The value of the /RD pin comes from the internal `RD` signal that comes out of [VRAM controller](#vram-controller).

### /WR

<img src="/BreakingNESWiki/imgstore/ppu/pad_wr.jpg" width="600px">

The /WR signal is complementary to the /RD signal (they cannot both be 0, but they can both be 1 when the VRAM interface is not in use).

When /WR=0 the AD0-AD7 data bus is used to write VRAM data (output).

The value of the /WR pin comes from the internal `WR` signal that comes out of [VRAM controller](#vram-controller).

## Interface with other PPUs

This interface is implemented by the EXT0-EXT3 inout pins.

<img src="/BreakingNESWiki/imgstore/ppu/pad_ext.jpg" width="600px">

Developers have made provisions for the interaction of several PPUs. The scheme of interaction is simple and looks as follows:
- Inside the PPU is a [multiplexer](#multiplexer) that can optionally send a "picture" to both the screen or the external EXT pins
- The multiplexer can also receive a "picture" from the external EXT pins

The term "picture" refers to a set of abstract video data to explain the interaction between the PPUs.

So PPUs could be connected in a chain and each PPU could "mix" its part of the picture with the resulting "picture".

The synchronization between PPUs is done simply by the sequence of EXT pins output and receive data (see multiplexer). The patent suggests that, for additional synchronization of the PPUs, their /RES pins should be combined so that all H/V registers and counters are reset simultaneously.

![ext_pads](/BreakingNESWiki/imgstore/ppu/ext_pads.png)

![pads_ext](/BreakingNESWiki/imgstore/ppu/pads_ext.jpg)

## Control signals

### CLK

Contact pad:

![pad_clk](/BreakingNESWiki/imgstore/ppu/pad_clk.jpg)

Resembles the relaxation oscillator: https://en.wikipedia.org/wiki/Schmitt_trigger#Use_as_an_oscillator

CLK distribution logic:

![PPU clk](/BreakingNESWiki/imgstore/ppu/clk.jpg)

The input CLK is split into two internal complementary signals: CLK and /CLK.

CLK is used exclusively in the phase generator of the PPU video path.

All other circuits are clocked by [Pixel Clock](#pixel-clock-pclk)

### /RES

![pad_res](/BreakingNESWiki/imgstore/ppu/pad_res.jpg)

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

Output analog [video signal](#ntsc-video).

## Logic

Logic of all terminals in single picture:

![pads_all](/BreakingNESWiki/imgstore/ppu/pads_all.jpg)

# Pixel Clock (PCLK)

Pixel clock (abbreviated as PCLK) is used by all PPU parts (except the video phase generator).

Both low level (`/PCLK`) and high level (`PCLK`) are used symmetrically. This approach of internal cycle implementation was widespread in the era of NMOS chips. Therefore, when analyzing PPU circuits, one should not think of PCLK as the clock signal, but rather the two "states" - PCLK=1 and PCLK=0.

Sometimes intuitively, PCLK is also called the "left half of the pixel" and /PCLK the "right half of the pixel". [^1]

The `PCLK` is obtained by slowing down (dividing) the input clock signal `CLK` (21.48 MHz) by a factor of 4.

For this purpose, a divider on dynamic latches is used:

<img src="/BreakingNESWiki/imgstore/ppu/pclk.jpg" width="400px">

Just below the divider is the single phase splitter. This is a canonical circuit based on a single FF that makes two phases (/PCLK + PCLK) from a single phase (PCLK).

At the output of the divider there are many push/pull amplifier stages, because the `PCLK` signal must be powerful enough, because it is distributed practically over the whole chip. For this purpose (just to the right of the chip) there is a comb of even more powerful push/pull inverters:

![pclk_amp](/BreakingNESWiki/imgstore/ppu/pclk_amp.jpg)

The `CLK` input clock signal is used exclusively in the [phase generator](#video-signal-generator) of the PPU video path.

Timings:

|PPU|CLK|CLK Cycle Duration|PCLK|PCLK Cycle Duration|
|---|---|---|---|---|
|NTSC|21477272 Hz|~0,046 µs|5369318 Hz|~0,186 µs|
|PAL|26601712 Hz|~0,037 µs|5320342.4 Hz|~0,187 µs|

## Power On Status

It is hard to say what values are on the latches (gates). If we assume that after power-up `CLK` is 0 and `z` (in HDL terms meaning "disconnected") on the gate is the same as 0 (gate closed), then the latch values will take the following values: [ 0, 1, 0, 1 ]

(The first latch is next to the `RES` signal.)

But in general it is more correct to assume that the value of the latches is undefined (`x`)

## Reset Status

![pclk_reset](/BreakingNESWiki/imgstore/ppu/pclk_reset.png)

## Logic Circuit

![pclk_2C02G](/BreakingNESWiki/imgstore/ppu/pclk_2C02G.jpg)

## PCLK Distribution

The following are the distinguishing features of PCLK distribution.

![2C02G_PCLK_Distrib_sm](/BreakingNESWiki/imgstore/ppu/2C02G_PCLK_Distrib_sm.png)

|Feature|Description|
|---|---|
|1|CLK Distribution|
|2|PCLK Divider|
|3|Single phase splitter. Outputs two symmetrical phases: /PCLK and PCLK|
|4|Inverting super buffer for /PCLK and PCLK|
|5|Local PCLK pullups|
|6|"Other" /PCLK (`/PCLK2`) used in sprite comparison logic|
|7|OB Pass. Transistors to form the input latches of the sprite comparator|
|8|THO Pass. Transistors to form THOx input latches for multiplexer inputs|
|9|OAM PCLK Precharge|
|10|CRAM PCLK Precharge|
|11|PCLK Anti-jitter. Transistors are used to accelerate the "dissipation" of the signal|
|12|/PCLK output for EXT terminals|

Full-size image: https://github.com/emu-russia/breaks/blob/master/Docs/PPU/2C02G_PCLK_Distrib.jpg

[^1]: For those who have been using Visual2C02 for a long time, the mapping of signals is as follows: PCLK=pclk0, /PCLK=pclk1.

# PPU Registers

![ppu_locator_regs](/BreakingNESWiki/imgstore/ppu/ppu_locator_regs.jpg)

This section describes only the control registers of the PPU ($2000/$2001) and the auxiliary logic that belongs to the CPU interface.

The other registers are evenly "spread out" over all parts of the PPU and are part of the control logic of the corresponding units and are treated separately.

Note: Here and below we give the usual NES/Famicom register notation starting at address $2000. But this mapping is done outside the PPU. Inside the PPU the registers are indexed as $0-$7.

CPU Interface:

|Name|Direction (in relation to PPU)|Description|
|---|---|---|
|R/W|input|Read-notWrite. Used to read/write PPU registers. If R/W = 1 it reads, otherwise it writes. The contact is easy to remember: "Read(1), do not write".|
|D0-D7|inOut|The data bus for transferring register values. When /DBE = 1 the bus is disconnected (Z)|
|RS0-RS2|input|Register Select. Sets the PPU register number (0-7)|
|/DBE|input|Data Bus Enable. If /DBE = 0, then the D0-D7 bus is used to exchange values with the PPU registers, otherwise the bus is disconnected.|

## R/W Decoder

The circuit is located above the sprite logic.

The decoder is designed to obtain two complementary control lines `/RD` and `/WR` from the input pad of the CPU R/W interface, which are used for the external data bus D0-D7. The /RD and /WR signals are complementary when /DBE = 0. If /DBE = 1 (CPU interface disabled) both signals are `1` (neither read nor write).

|![rw_decoder](/BreakingNESWiki/imgstore/ppu/rw_decoder.jpg)|![rw_decoder_logic](/BreakingNESWiki/imgstore/ppu/rw_decoder_logic.jpg)|
|---|---|

## Read/Write Enablers

Next to the circuits that use registers there are small circuits that we call Read/Write Enablers.

An example of such a circuit, the R4 Enabler (located to the left of the RW decoder):

![r4_enabler_tran](/BreakingNESWiki/imgstore/ppu/r4_enabler_tran.jpg)

![rw_enabler_logic](/BreakingNESWiki/imgstore/ppu/rw_enabler_logic.jpg)

## Register Select

The circuit is on the right side of the H/V counters.

The circuit is engaged in selecting a register operation. The input is:
- RS0-2 (CPU interface input pads): PPU register index (0-7)
- R/W: Type of operation (read or write)

The output of the circuit produces many control lines which activate a read or write operation for the corresponding register (e.g. `/R7` - means "Read register $2007")

|![reg_select](/BreakingNESWiki/imgstore/ppu/reg_select.jpg)|![reg_select_logic](/BreakingNESWiki/imgstore/ppu/reg_select_logic.jpg)|
|---|---|

## $2005/$2006 Special Processing

As you know, 2 consecutive writes to registers $2005 or $2006 actually write a value to the [dual registers $2005/$2006](#scroll-registers) (FV/FH/TV/TH).

A latch circuit is used to keep track of the write history in $2005/$2006.

The latch only remembers the order of access (1 or 2), but not the register number. Therefore, if the first write to register $2005, the next write to register $2006 will be treated as the second write.

The latch is reset by the `RC` signal or by reading register $2002.

![scc_first_second_logic](/BreakingNESWiki/imgstore/ppu/scc_first_second_logic.jpg)

## Control Registers

The circuitry is below the sprite logic above the multiplexer (MUX).

<img src="/BreakingNESWiki/imgstore/ppu/control_regs.jpg" width="1000px">

Single bit circuit:

![reg_ff_logic](/BreakingNESWiki/imgstore/ppu/reg_ff_logic.jpg)

Control Regs Logic:

|PPU CTRL0 ($2000)|PPU CTRL1 ($2001)|
|---|---|
|![ctrl0](/BreakingNESWiki/imgstore/ppu/ctrl0.jpg)|![ctrl1](/BreakingNESWiki/imgstore/ppu/ctrl1.jpg)|

The official name of the registers (as strange as it may seem now): CTLR0 and CTLR1 (not a typo).

### Special Note

It should be understood that the access to the PPU registers is not related to PCLK in any way. Therefore, programmer can interfere with PPU rendering process at any time.
Technically it can be done, but it is not recommended because it can lead to different side-effects. Information on when registers can be accessed without consequences can be found in any PPU Reference Manual.

But on the other hand it can be used (and is used in games in fact) to get interesting visual effects.

## Clipping

Below the control registers is a small circuit, for getting the control signals `/CLPB` and `CLPO`:

|![clp_tran](/BreakingNESWiki/imgstore/ppu/clp_tran.jpg)|
|---|
|![clp_logic](/BreakingNESWiki/imgstore/ppu/clp_logic.jpg)|

It's supposed to belong more to control logic, but topologically it's in a completely different place, so it's discussed in this section.

This is the place to talk about the zoo of signals associated with Clipping.

|Signal|From|Where To|Description|
|---|---|---|---|
|/BGCLIP|Regs $2001\[1\]|FSM|0: Clip the left 8 pixels in the line for the background|
|/OBCLIP|Regs $2001\[2\]|FSM|0: Clip the left 8 pixels in the line for the sprites|
|CLIP_B|FSM|Regs|1: Enabled if left 8 background pixels clipping is on and it is time (H counter is set to the right value)|
|CLIP_O|FSM|Regs|1: Enabled if left 8 sprite pixels clipping is on and it is time (H counter is set to the right value)|
|/CLPB|Regs|BGCOL|0: Clip background. Final signal for BGCOL circuit|
|CLPO|Regs|FIFO|1: Clip sprites. Final signal for OAM FIFO circuit|

# H/V Counters

![ppu_locator_hv](/BreakingNESWiki/imgstore/ppu/ppu_locator_hv.jpg)

H/V counters count the number of pixels per line and the number of lines, respectively. H ticks from 0 to 340 (including), V ticks from 0 to 261 (including). The total visible and invisible part of the screen is 262 lines of 341 pixels each.

Technically the counters consist of 9 bits, so they can count from 0 to 0x1FF, but they never count completely and are limited to the maximum H and V values. To do this, the H/V FSM circuit periodically resets them.

## Counter Bit

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

|H|V|
|---|---|
|![H_trans](/BreakingNESWiki/imgstore/ppu/H_trans.jpg)|![V_trans](/BreakingNESWiki/imgstore/ppu/V_trans.jpg)|

- HCounter always counts because the carry_in of bit 0 is always 1 (connected to Vdd)
- VCounter increments by 1 only when input `V_IN` is active
- The output carry of each previous bit is set to the input carry of the next bit to form the carry-chain
- Each counter includes additional transfer logic (below), for this reason I had to post large pictures of counters to see this logic

![HV_Counters](/BreakingNESWiki/imgstore/ppu/HV_Counters.jpg)

## Extra Carry Logic

Counters include a little piece like this:

|HCounter|VCounter|
|---|---|
|![CARRYH](/BreakingNESWiki/imgstore/ppu/CARRYH.jpg)|![CARRYV](/BreakingNESWiki/imgstore/ppu/CARRYV.jpg)|
|![CarryH_Logic](/BreakingNESWiki/imgstore/ppu/CarryH_Logic.jpg)|![CarryV_Logic](/BreakingNESWiki/imgstore/ppu/CarryV_Logic.jpg)|

The circuit for HCounter does not include an analog to V_IN because the input carry for H is always 1 and is not required for the NOR operation that this extra logic represents.

What's it for? Probably to reduce the propagation delay of the carry chain.

In simulation, you can do quite well without these "patches", the operation of the counters won't be any different.

# H/V Decoder

![ppu_locator_hv_dec](/BreakingNESWiki/imgstore/ppu/ppu_locator_hv_dec.jpg)

The H/V decoder selects the necessary pixels and lines for the rest of H/V logic.

A "pixel" refers to a time interval that is based on PCLK. Not all "pixels" are displayed as an image, some are defined by different control portions of the signal, such as HSync, Color Burst, etc.

The principle of operation is as follows:
- The inputs are on the left, the outputs on the bottom. The inputs for the counter digits are in top-down order, starting from msb, for example: H8, /H8, H7, /H7 etc.
- The direct and inverse inputs are needed to check the value of the corresponding digit to `0` or `1`. For example, if the bit H8=1 and there is a transistor in the decoder, the output is "zeroed" (inactive).
- Each output takes the value `1` only for the required H or V values
- H Decoder has 2 additional inputs: VB and BLNK, which cut off the corresponding outputs when VB=1 or BLNK=1
- Technically, each decoder line is a multi-input NOR gate

Another topological feature of the H/V decoder is the lower left corner, the outputs from which go to the left, not down, into the Front Porch circuit.

## H Decoder

![ntsc_h](/BreakingNESWiki/imgstore/ppu/ntsc_h.png)

|HPLA output|Pixel numbers of the line|Bitmask|VB Tran|BLNK Tran|Involved|
|---|---|---|---|---|---|
|0|279|01101010011001010100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS (also /EVAL)|
|6|63|10101001010101010101| |yes|/EVAL|
|7|255|00010101010101010101| |yes|E/EV (also /EVAL)|
|8|0-63|10101000000000000001| |yes|I/OAM2|
|9|256-319|01101000000000000001| |yes|PAR/O|
|10|0-255|10000000000000000011|yes|yes|/VIS|
|11|Each 0..1|00000000000010100001| |yes|#F/NT|
|12|Each 6..7|00000000000001010000| | |F/TB|
|13|Each 4..5|00000000000001100000| | |F/TA|
|14|320-335|01000110100000000001| |yes|/FO|
|15|0-255|10000000000000000001| |yes|F/AT|
|16|Each 2..3|00000000000010010000| | |F/AT|
|17|270|01101010100101011000| | |BPorch FF|
|18|328|01100110100110101000| | |BPorch FF|
|19|279|01101010011001010100| | |HBlank FF|
|20|304|01101001011010101000| | |HBlank FF|
|21|323|01100110101010010100| | |BURST FF|
|22|308|01101001011001101000| | |BURST FF|
|23|340|01100110011001101000| | |HCounter clear / VCounter step|

![H_Decoder](/BreakingNESWiki/imgstore/ppu/H_Decoder.jpg)

## V Decoder

![ntsc_v](/BreakingNESWiki/imgstore/ppu/ntsc_v.png)

|VPLA output|Line number|Bitmask|Involved|
|---|---|---|---|
|0|247|000101010110010101|VSYNC FF|
|1|244|000101010110011010|VSYNC FF|
|2|261|011010101010011001|PICTURE FF|
|3|241|000101010110101001|PICTURE FF|
|4|241|000101010110101001|/VSET|
|5|0|101010101010101010|VB FF|
|6|240|000101010110101010|VB FF, BLNK FF|
|7|261|011010101010011001|BLNK FF|
|8|261|011010101010011001|VCLR|

![V_Decoder](/BreakingNESWiki/imgstore/ppu/V_Decoder.jpg)

# PPU FSM

![ppu_locator_hv_fsm](/BreakingNESWiki/imgstore/ppu/ppu_locator_hv_fsm.jpg)

The H/V logic is a finite state machine (FSM) that controls all other PPU parts. Schematically it is just a set of latches, like "this latch is active from 64th to 128th pixel", so the corresponding control line coming from this latch is also active.

The H/V FSM includes the following components:
- Delayed counter H value output circuits
- Horizontal logic associated with an H decoder
- Vertical logic associated with the V decoder
- PPU interrupt handling (VBlank)
- EVEN/ODD circuitry
- H/V counter control circuitry

![hv_fsm_all](/BreakingNESWiki/imgstore/ppu/hv_fsm_all.jpg)

The control logic is loaded with all kinds of signals that come and go to almost every possible PPU component.

Inputs:

|Signal|From|Description|
|---|---|---|
|H0-5|HCounter|HCounter bits 0-5, for outputting to the outside with a delay.|
|V8|VCounter|VCounter bit 8. Used in EVEN/ODD logic.|
|/V8|VDecoder|VCounter bit 8 (inverted). Used in EVEN/ODD logic.|
|HPLA_0-23|HDecoder|Outputs from H decoder|
|VPLA_0-8|VDecoder|Outputs from V decoder|
|/OBCLIP|Control Regs ($2001\[2\])|To generate the `CLIP_O` control signal|
|/BGCLIP|Control Regs ($2001\[1\])|To generate the `CLIP_B` control signal|
|BLACK|Control Regs|Active when PPU rendering is disabled (see $2001\[3\] and $2001\[4\])|
|DB7|Internal data bus DB|To read $2002\[7\]. Used in the VBlank interrupt handling circuit.|
|VBL|Control Regs ($2000\[7\])|Used in the VBlank interrupt handling circuit.|
|/R2|Reg Select|Register $2002 read operation. Used in the VBlank interrupt handling circuit.|
|/DBE|/DBE Pad|Enable the CPU interface. Used in the VBlank interrupt handling circuit.|
|RES|/RES Pad|Global reset signal. Used in EVEN/ODD logic.|

Outputs:

|Signal|Where|Description|
|---|---|---|
|**HCounter delayed outputs**|||
|H0'|All|H0 signal delayed by one DLatch|
|/H1'|All|H1 signal delayed by one DLatch (in inverse logic)|
|/H2'|All|H2 signal delayed by one DLatch (in inverse logic)|
|H0''-H5''|All|H0-H5 signals delayed by two DLatch|
|**Horizontal control signals**|||
|S/EV|Sprite Logic|"Start Sprite Evaluation"|
|CLIP_O|Control Regs|"Clip Objects". 1: Do not show the left 8 screen pixels for sprites. Used to get the `CLPO` signal that goes into the OAM FIFO.|
|CLIP_B|Control Regs|"Clip Background". 1: Do not show the left 8 pixels of the screen for the background. Used to get the `/CLPB` signal that goes into the Data Reader.|
|0/HPOS|OAM FIFO|"Clear HPos". Clear the H counters in the [sprite FIFO](#oam-fifo) and start the FIFO|
|/EVAL|Sprite Logic|"Sprite Evaluation in Progress"|
|E/EV|Sprite Logic|"End Sprite Evaluation"|
|I/OAM2|Sprite Logic|"Init OAM2". Initialize an extra [OAM](#oam)|
|PAR/O|All|"PAR for Object". Selecting a tile for an object (sprite)|
|/VIS|Sprite Logic|"Not Visible". The invisible part of the signal (used by [sprite logic](#sprite-comparison-oam-evaluation))|
|#F/NT|Data Reader, OAM Eval|"Fetch Name Table"|
|F/TB|Data Reader|"Fetch Tile B"|
|F/TA|Data Reader|"Fetch Tile A"|
|/FO|Data Reader|"Fetch Output Enable"|
|F/AT|Data Reader|"Fetch Attribute Table"|
|SC/CNT|Data Reader|"Scroll Counters Control". Update the scrolling registers.|
|BURST|Video Out|Color Burst|
|SYNC|Video Out|Horizontal sync pulse|
|**Vertical control signals**|||
|VSYNC|Video Out|Vertical sync pulse|
|/PICTURE|Video Out|Visible part of the scan-lines|
|VB|HDecoder|Active when the invisible part of the video signal is output (used only in H Decoder)|
|BLNK|HDecoder, All|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|RESCL (VCLR)|All|"Reset FF Clear" / "VBlank Clear". VBlank period end event. Initially the connection was established with contact /RES, but then it turned out a more global purpose of the signal. Therefore, the signal has two names.|
|**Misc**|||
|HC|HCounter|"HCounter Clear"|
|VC|VCounter|"VCounter Clear"|
|V_IN|VCounter|"VCounter In". Increment the VCounter|
|INT|/INT Pad|"Interrupt". PPU Interrupt|

Auxiliary signals:

|Signal|From|Where|Description|
|---|---|---|---|
|/FPORCH|Horizontal logic (FPORCH FF)|Obtaining the `SYNC` control signal|"Front Porch"|
|BPORCH|Horizontal logic (BPORCH FF)|Obtaining the `/PICTURE` control signal|"Back Porch"|
|/HB|Horizontal logic (HBLANK FF)|Obtaining the `VSYNC` control signal|"HBlank"|
|/VSET|Vertical logic|VBlank interrupt handling circuit|"VBlank Set". VBlank period start event.|
|EvenOddOut|EVEN/ODD circuit|H/V counter control|Intermediate signal for the HCounter control circuit.|

## Delayed H Outputs

The H0-H5 counter bits are used in other PPU components.

A signal name with one dash (e.g. `/H2'`) means that the value is delayed by one DLatch. A signal name with two dashes (e.g. `H0''`) means that the value is delayed by two DLatch.

The reason the H-counter values are delayed is because the counter is clocked by the same signal (PCLK) as the other circuits. If the current H values were not latched, the whole PPU circuit would go into autogeneration.

|Transistor Circuit|Logic|
|---|---|
|![h_counter_output](/BreakingNESWiki/imgstore/ppu/h_counter_output.jpg)|![h_counter_output_logic](/BreakingNESWiki/imgstore/ppu/h_counter_output_logic.jpg)|

## HPos Logic

"Horizontal" logic, responsible for generating control signals depending on the horizontal position of the beam (H):

Transistor Circuit:

![hv_fporch](/BreakingNESWiki/imgstore/ppu/hv_fporch.jpg)

![hv_fsm_horz](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz.jpg)

Logic:

![hv_fsm_horz_logic](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz_logic.jpg)

As a result, the circuit generates the following signal diagram:

![ppu_ntsc_line](/BreakingNESWiki/imgstore/ppu/ppu_ntsc_line.png)

(Some signals such as `/FO` are "highlighted" in the diagram in an inverse way to make the picture clearer)

## VPos Logic

"Vertical" logic.

Transistor Circuit:

![hv_fsm_vert](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert.jpg)

Logic:

![hv_fsm_vert_logic](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert_logic.jpg)

## VBlank Interrupt Handling

|Transistor Circuit|Logic|
|---|---|
|![hv_fsm_int](/BreakingNESWiki/imgstore/ppu/hv_fsm_int.jpg)|![hv_fsm_int_logic](/BreakingNESWiki/imgstore/ppu/hv_fsm_int_logic.jpg)|

Principle of operation:
- There is an edge detector on the input that catches the VBlank start event (`/VSET` signal)
- The VBlank start event is memorized on INT_FF
- The `RESCL(VCLR)` signal clears INT_FF
- Output signal `INT` goes to external contact `/INT` to signal external devices to interrupt (CPU)
- The programmer can find out the state of the interrupt flag (INT_FF) by reading $2002\[7\]. The FF where the flag is stored is designed so that reading the flag also clears it (see 3-NOR on one of the FF arms).

## EVEN/ODD Logic

![even_odd_tran](/BreakingNESWiki/imgstore/ppu/even_odd_tran.jpg)

(The circuit is placed "on its side" for convenience)

The EVEN/ODD logic consists of two FFs closed to each other, controlled by two multiplexers. It turns out to be a miniature Johnson counter.

This circuit implements the so-called NTSC Crawl logic. It is necessary to eliminate 1 pixel output each frame to remove the multiplicity of PCLK and color subcarrier, to avoid artifacts on the B/W TV.

![even_odd_logic](/BreakingNESWiki/imgstore/ppu/even_odd_logic.jpg)

## H/V Counters Control

Transistor Circuit:

![hv_counters_control](/BreakingNESWiki/imgstore/ppu/hv_counters_control.jpg)

Logic:

![hv_counters_control_logic](/BreakingNESWiki/imgstore/ppu/hv_counters_control_logic.jpg)

# Color RAM

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

The logic for working with the palette includes the following circuits:
- Color Buffer (CB)
- Color Buffer control circuitry
- Palette memory (Color RAM)
- Decoder of the palette index, coming from the output of the multiplexer

![CRAM_All](/BreakingNESWiki/imgstore/ppu/CRAM_All.jpg)

Signals:

|Signal|From|Purpose|
|---|---|---|
|/R7|Reg Select|Read $2007|
|/DBE|/DBE Pad|"Data Bus Enable", enable CPU interface|
|TH/MUX|VRAM Ctrl|Send the TH Counter value to the MUX input, which will cause the value to go into the palette as Direct Color.|
|/PICTURE|FSM|The visible part of the video signal with the picture is generated|
|B/W|Regs $2001\[0\]|Disable Color Burst, to generate a monochrome picture|
|DB/PAR|VRAM Ctrl|Control signal|
|#DB/CB|Color Buffer Control|0: DB -> CB|
|#CB/DB|Color Buffer Control|0: CB -> DB|

## Color Buffer (CB)

The Color Buffer (CB) is used to store the current "pixel" for the phase generator and to read/write the palette memory (using the CPU interface).

### Color Buffer Control

![cb_control](/BreakingNESWiki/imgstore/ppu/cb_control.jpg)

![CB_Control_Logic](/BreakingNESWiki/imgstore/ppu/CB_Control_Logic.jpg)

### CB Bit

|![color_buffer_bit](/BreakingNESWiki/imgstore/ppu/color_buffer_bit.jpg)|![cb_bit_logisim](/BreakingNESWiki/imgstore/ppu/cb_bit_logisim.jpg)|
|---|---|

The Logisim schematic is a very approximation of the original one, because Logisim does not support inOut entities.

### CB Output Delay

The outputs from the CB bits do not go directly to the phase generator, but go through a D-Latch chain. The D-Latch chains are unequally spaced for each CB bit.

Delays are necessary due to the fact that logically it is not possible to process the current pixel and simultaneously display it as a signal. Therefore, the video generator essentially outputs pixels "from the past".

For CB bits 4-5 (luminance, LL0# and LL1# signals):

![cbout_ll](/BreakingNESWiki/imgstore/ppu/cbout_ll.jpg)

For CB bits 0-3 (chrominance, CC0-3# signals), only part of the chain is next to the CB. The rest of the latches are scattered like breadcrumbs along the way to [phase generator](#video-signal-generator).

![cbout_cc](/BreakingNESWiki/imgstore/ppu/cbout_cc.jpg)

P.S. If you are a chip designer, please don't spread your topology out like this. Such circuits are very inconvenient to saw into pieces for study and post on the wiki.

### Black/White Mode

The outputs of the 4 bit CB responsible for the chrominance are controlled by the `/BW` control signal.

A similar transistor for the 2 luminance bits is simply always open:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu/ppu_luma_tran.jpg)

## Color RAM Layout

By convention, groups of cells that are addressed by the lowest bits of the address will be considered "rows", and groups of cells that are addressed by the highest bits will be considered "columns".

Color RAM:
- PAL3, PAL2: Defines column (PAL3 - msb)
- PAL4, PAL1, PAL0: Defines a row (PAL4 - msb)
- Rows 0 and 4 combined

It looks a bit chaotic, but it is what it is. Reverse engineering of memory for some reason always goes with this kind of agony of understanding, but don't forget the fact that the order in which the address lines are connected for memory indexing is generally irrelevant.

COL outputs:

![cram_col_outputs](/BreakingNESWiki/imgstore/ppu/cram_col_outputs.jpg)

PCLK Precharge:

![cram_precharge](/BreakingNESWiki/imgstore/ppu/cram_precharge.jpg)

Additionally, you can see the CRAM cell allocation map here: https://github.com/ogamespec/CRAMMap

### Memory Cell

The memory cell is a typical 4T SRAM Cell:

|![cram_cell_topo](/BreakingNESWiki/imgstore/ppu/cram_cell_topo.jpg)|![cram_cell](/BreakingNESWiki/imgstore/ppu/cram_cell.jpg)|
|---|---|

The value is written or read with two complementary inOut: /val and val. The principle of cell operation:
- In cell read mode: /val = val = `z`. Therefore, the current value is output to the outside.
- In cell write mode: /val and val take the complementary value of the bit to be written

### CRAM Index Decoder

:warning: Note that the PAL4 signal does not follow the usual order. This bit selects the type of palette: palette for the background or for the sprites.

|![cram_decoder](/BreakingNESWiki/imgstore/ppu/cram_decoder.jpg)|![cram_decoder_logic](/BreakingNESWiki/imgstore/ppu/cram_decoder_logic.jpg)|
|---|---|

|COL0 \| COL1 \| COL2 \| COL3|
|---|
|ROW0+4|
|ROW6|
|ROW2|
|ROW5|
|ROW1|
|ROW7|
|ROW3|

A similar memory organization pattern is repeated 6 times for each Color Buffer bit.

## NTSC Video

The video signal layout is as follows:

![ntsc](/BreakingNESWiki/imgstore/ppu/ntsc.png)

- This picture shows a single line layout
- First there is the horizontal sync pulse (HSYNC), so that the beam is set to the beginning of the line
- After the HSYNC pulse is the "back porch" which contains a special "flash": 8-10 subcarrier pulses, for the phase locked loop (PLL). 
- Then comes the image signal itself
- The signal of the line ends with the so called "front porch"

Now for some clarification.

First - the NTSC standard was created with compatibility with black and white television in mind. In the B&W signal, you could only set the brightness of the signal, which simply changed depending on the amplitude. Back porch and front porch were black borders on the left and right sides of the screen.

To add a color component, the developers added phase modulation:

<img src="/BreakingNESWiki/imgstore/ppu/ntsc_color.gif" width="700px">

At the same time, the average amplitude again remained brightness, and the phase shift within the phase "package" and the amplitude began to represent chromaticity. At the same time black and white TV sets did not perceive the phase component and worked only by the averaged amplitude.

To tell the decoder where the 0<sup>o</sup> is, a special "color burst" was added. The phase shift is counted relative to the oscillation of this burst.

The color component consists of two components: Saturation and Hue. Saturation is determined by the amplitude of the phase component, and Hue by the phase shift.

## Framing

Now let's talk about how one image frame is formed.

We must take into account the fact that the decomposition of a video signal into a line of pixels does not oblige the TV set to have a fixed number of pixels. A TV set has no pixels at all in the conventional sense. It has "grains." A signal can be "smeared" as much as 100 grains wide or as much as 1,000. This is a feature of the cathode ray tube.

The surface of a kinescope of old color TVs looks like this:

<img src="/BreakingNESWiki/imgstore/ppu/crt_screen_closeup.jpg" width="500px">

The saturation and hue encoded in the color component of the subcarrier sets the brightness of the three electron beams: red, blue, and green. The rays fall on the grains, which are coated with a phosphor. The phosphor has an afterglow: after the beam has passed over the grain, it continues to glow for some time (usually fading after a few scanlines).

In contrast to the width, the number of lines of 1 full frame is clearly fixed by the NTSC standard and is 525 lines. Of these 525 lines, about 480 lines are dedicated directly to the image, and the rest are used for vertical synchronization (VSync).

"Approximately 480" because different TV models may actually output less, due to the tube design and construction of the TV. In doing so, some of the image may be hidden behind the edge of the screen.

## Other Features

The frame is output in two halves, using interlace method. The odd lines 1, 3, 5 etc. are output first, and then the even lines 0, 2, 4 etc. But in general it does not matter in what order to start the output, when forming an image it does not matter. When you turn the TV on, the beam starts scanning the screen (remember the "germ war"?) and the framing can start anywhere on the screen, after the receiver receives an adequate video signal.

The NTSC line frequency is 15734 Hz, and the frame frequency (or rather, half-frame frequency) is 59.94 Hz. This was done to reduce interference from subcarrier and audio. But the interference has not disappeared completely and appears in the form of "waves".

# Video Signal Generator

![ppu_locator_vid_out](/BreakingNESWiki/imgstore/ppu/ppu_locator_vid_out.jpg)

![vidout_logic](/BreakingNESWiki/imgstore/ppu/vidout_logic.jpg)

Input signals:

|Signal|From|Description|
|---|---|---|
|/CLK|CLK Pad|First half of the PPU cycle|
|CLK|CLK Pad|Second half of the PPU cycle|
|/PCLK|PCLK Distribution|First half of the Pixel Clock cycle|
|PCLK|PCLK Distribution|Second half of the Pixel Clock cycle|
|RES|/RES Pad|Global reset|
|#CC0-3|Color Buffer|4 bits of the chrominance of the current "pixel" (inverted value)|
|#LL0-1|Color Buffer|2 bits of the luminance of the current "pixel" (inverted value)|
|BURST|FSM|Color Burst|
|SYNC|FSM|Sync pulse|
|/PICTURE|FSM|Visible part of the scan-lines|
|/TR|Regs $2001\[5\]|"Tint Red". Modifying value for Emphasis|
|/TG|Regs $2001\[6\]|"Tint Green". Modifying value for Emphasis|
|/TB|Regs $2001\[7\]|"Tint Blue". Modifying value for Emphasis|

## Phase Shifter

![vout_phase_shifter](/BreakingNESWiki/imgstore/ppu/vout_phase_shifter.jpg)

![vidout_phase_shifter_logic](/BreakingNESWiki/imgstore/ppu/vidout_phase_shifter_logic.jpg)

Schematic of a single bit shift register used in the phase shifter circuit:

![vidout_sr_bit_logic](/BreakingNESWiki/imgstore/ppu/vidout_sr_bit_logic.jpg)

If you dump each half-cycle phase shifter outputs and match them to the PPU color number with which it is associated, you get this:

```
123456......
12345......C
1234......BC
123......ABC
12......9ABC
1......89ABC
......789ABC
.....6789AB.
....56789A..
...456789...
..345678....
.234567.....
```

If you split the dump from the beginning of the PPU into pixels (8 half-cycles per pixel, according to the PCLK divider), you get the following:

```
.2.4.6.8.A.C
.2.4.6.8.A..
.2.456.8.A..
.2.456.8....
.23456.8....
.23456......
123456......
12345......C

1234......BC
123......ABC
12......9ABC
1......89ABC
......789ABC
.....6789AB.
....56789A..
...456789...

..345678....
.234567.....
123456......
12345......C
1234......BC
123......ABC
12......9ABC
1......89ABC

......789ABC
.....6789AB.
....56789A..
...456789...
..345678....
.234567.....
123456......
12345......C
```

That is, the first pixel phase shifter first "comes to its senses", and then begins to output 12 phases. Note that the phases do not correspond to the "boundaries" of the pixels, so the phase will "float". But since all phases "float" simultaneously with the phase that is used for Color Burst - the overall phase pattern will not be disturbed.

![cb_drift](/BreakingNESWiki/imgstore/ppu/cb_drift.png)

## Chrominance Decoder

![vout_phase_decoder](/BreakingNESWiki/imgstore/ppu/vout_phase_decoder.jpg)

![vidout_chroma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_chroma_decoder_logic.jpg)

The color decoder selects one of the 12 phases. 12 because:
- Gray halftones do not need a phase.
- There is no phase for colors 13-15. However, for color 13 there is an option to use brightness, and colors 14-15 are forced to be "Black" using the `PBLACK` signal

Table of matching decoder outputs and PPU colors:

|Color decoder output|Corresponding PPU color|Phase shift|
|---|---|---|
|0|12|120°|
|1|5|270°|
|2|10|60°|
|3|3|210°|
|4|0. Not connected to the phase shifter because gray halftones do not need a phase.| |
|5|8. Also used for the Color Burst phase|0°|
|6|1|150°|
|7|6|300°|
|8|11|90°|
|9|4|240°|
|10|9|30°|
|11|2|180°|
|12|7|330°|

(The numbering of the decoder outputs is topological, from left to right, starting from 0).

## Luminance Level

|![vout_level_select](/BreakingNESWiki/imgstore/ppu/vout_level_select.jpg)|![vidout_luma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_luma_decoder_logic.jpg)|
|---|---|

The brightness decoder selects one of 4 brightness levels.

Waveform of the visible part of the video signal at different luminance values (`LU`):

![vid_levels](/BreakingNESWiki/imgstore/ppu/vid_levels.png)

(Emphasis is not shown, see below)

## Emphasis

|![vout_emphasis](/BreakingNESWiki/imgstore/ppu/vout_emphasis.jpg)|![vidout_emphasis_logic](/BreakingNESWiki/imgstore/ppu/vidout_emphasis_logic.jpg)|
|---|---|

If a dimming color is selected in the phase shifter and dimming for that color is enabled in the control register $2001, it activates the `TINT` signal, which slightly lowers the voltage levels, thereby dimming the color.

The `TINT` signal can only be applied to the visible part of the video signal (see /POUT signal).

## DAC

![vout_dac](/BreakingNESWiki/imgstore/ppu/vout_dac.jpg)

![vidout_dac_logic](/BreakingNESWiki/imgstore/ppu/vidout_dac_logic.jpg)

Level values of the unloaded video signal:

|L|Absolute V|Description|
|---|---|---|
|0|0.781|Synch|
|1|1.000|Colorburst L|
|2|1.131|Color 0D|
|3|1.300|Color 1D (black)|
|4|1.712|Colorburst H|
|5|1.743|Color 2D|
|6|1.875|Color 00|
|7|2.287|Color 10|
|8|2.331|Color 3D|
|9|2.743|Color 20 / 30|

If the `TINT` signal value is 1, the voltage is multiplied by approx. 0.746f.

# Sprite Comparison (OAM Evaluation)

![ppu_locator_sprite_eval](/BreakingNESWiki/imgstore/ppu/ppu_locator_sprite_eval.jpg)

The sprite comparison circuit compares all 64 sprites and selects the first 8 sprites that occur first on the current line (V). The fact that the PPU can only draw the first 8 sprites of a line is a well-known fact that has to be taken into account when programming NES. Usually programmers use sprite shuffling, but even this has the effect of "flickering" sprites.

The selected sprites are placed in additional memory OAM2, from where they then go to [OAM FIFO](#oam-fifo) for further processing.

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

The `H0''` signal which is used in the counter control circuits does not come from the H-Outputs which are in the [PPU FSM](#ppu-fsm) circuit, but is derived by the circuit which is in between the connections to the left of the sprite logic.

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

Operating modes of OAM counters:

|OAM Counter|Size (bits)|Modulo|Read/Write OAM via $2003/$2004|Initialization|Comparison (search)|Comparison (copy)|Fetching sprites from Temp OAM to FIFO|
|---|---|---|---|---|---|---|---|
|OAM|8|+1 / +4|working, modulo +1|not working|working, modulo +4|working, modulo +1|not working|
|Temp OAM|5|+1|not working|working|not working|working|working|

## OAM Address

![oam_address_tran](/BreakingNESWiki/imgstore/ppu/oam_address_tran.jpg)

![OAM_Address](/BreakingNESWiki/imgstore/ppu/OAM_Address.png)

## Comparator

![oam_cmpr](/BreakingNESWiki/imgstore/ppu/oam_cmpr.jpg)

![OAM_CmpBitPair](/BreakingNESWiki/imgstore/ppu/OAM_CmpBitPair.png)

The even and odd bits of the comparator are combined into a single circuit, to compact the inverted carry chain. Between "duplets" the carry chain is kept in direct logic.

Since the circuit is essentially a subtractor, it is more appropriate to say "borrow" instead of "carry", but the phrase "borrow chain" is not commonly used, so "carry chain" is used.

![OAM_Cmp](/BreakingNESWiki/imgstore/ppu/OAM_Cmp.png)

The opening transistors for the input latches are next to the OAM Buffer:

![oam_buffer_readback](/BreakingNESWiki/imgstore/ppu/oam_buffer_readback.jpg)

## Comparison Control

![oam_eval_control](/BreakingNESWiki/imgstore/ppu/oam_eval_control.jpg)

![OAM_EvalFSM](/BreakingNESWiki/imgstore/ppu/OAM_EvalFSM.png)

The nor+mux+FF arrangement is actually a Posedge DFFE. And the `#EN` (enable) input is in inverse logic.

![PosedgeDFFE](/BreakingNESWiki/imgstore/ppu/PosedgeDFFE.png)

:warning: Note that this circuit uses "Other /PCLK" (`/PCLK2`) instead of the usual `/PCLK`, which is obtained locally.
Practice and simulations have shown that such "Other CLKs" are important for the correct operation of the circuit.
In this case, this signal means that places where `/PCLK2` applies are triggered slightly later than other places where regular `/PCLK` applies.

## PD/FIFO

This signal is needed when PAR/O is active. At other times it does not have any effect. The meaning of this signal is to prohibit loading sprite comparison artifact into FIFO, provided that the sprites are less than 8, or sprites for the current line were not found. This artifact appears because of the simplified circuit of copying sprites from OAM to OAM2, because the write signal is active even if the copying has not begun. This cell gets the last value from memory when comparing sprites. 

In other words, if PD/FIFO = 1, then loading the pattern from PD (H. INV) is allowed, 0 is not allowed.

## Big Capacitor ("BigCap")

The `DO_COPY` signal is connected to a large capacitor, one lining of which is made of a piece of polysilicon and the other is the chip substrate (ground). This capacitor is needed to slightly delay the edge of the `DO_COPY` signal.

# Multiplexer

![ppu_locator_mux](/BreakingNESWiki/imgstore/ppu/ppu_locator_mux.jpg)

The PPU multiplexer is the little wicked circuit that deals with the selection of the pixel color, which is then fed to the palette memory input as an index, to select the final color for the [phase generator](#video-signal-generator).

As usual, "color" and "pixel" are understood as abstract concepts: color is the color/brightness combination for the phase generator, and pixel is part of the visible video signal.

Inputs:
- Background color (4 bits)
- Sprite color (4 bits)
- Color from external contacts (`EXT In`) (4 bits)
- Direct color from PAR TH Counter (5 bits)

Outputs:
- Color Index for Palette (5 bits)
- Color for external terminals (`/EXT Out`) (4 bits)

## Transistor Circuit

![mux](/BreakingNESWiki/imgstore/ppu/mux.jpg)

As you can see, the circuit looks very confusing at first glance. This is because the multiplexers (as circuit elements) are very difficult to recognize from the NMOS transistors.

The signals `THOx'` are obtained from the THO latches as follows:

![tho_latches_tran](/BreakingNESWiki/imgstore/ppu/tho_latches_tran.jpg)

(Located in the bottom right corner of the MUX).

## Logic

![mux_logic](/BreakingNESWiki/imgstore/ppu/mux_logic.jpg)

Control circuit:

![mux_control_logic](/BreakingNESWiki/imgstore/ppu/mux_control_logic.jpg)

Signals:

|Signal|Purpose|
|---|---|
|BGC0-3|The color of the background|
|/ZCOL0, /ZCOL1, ZCOL2, ZCOL3|Sprite color|
|EXT0-3 IN|Input color from EXT pins|
|THO0-4|Input color from TH counter|
|TH/MUX|Prioritizes the direct color from TH over all other colors|
|/ZPRIO|Prioritizes the sprite color over the background color (0: sprites on top)|
|/EXT0-3 OUT|The output color for EXT contacts|
|PAL0-4|Output color for palette indexing|

As you can see the circuit is a cascade of multiplexers, between which are D-Latch:
- The first state selects the color of the background/sprite. Which color is selected is determined by the circuit by the bits BGC0-1, /ZCOL0-1 and the priority of the sprites (/ZPRIO). The result of this circuitry is an internal `OCOL` control signal that is applied to the bit multiplexers;
- In the second state a choice is made between the previous result and the external color from the EXT pins;
- In the third state a choice is made between the result of the second state and the direct color from the TH (Tile Horizontal) counter. The priority of the direct color is set by the control signal `TH/MUX`.

"Direct color" is a special processing to access the palette memory from the CPU interface side. Since the palette memory is mapped to the PPU address space - when the palette is accessed, its index is temporarily stored on the PAR TH counter (5 bits). When this happens, the [VRAM controller](#vram-controller) sets the TH/MUX signal, which indicates that the TH counter contains the selected palette index (color). The outputs from the TH counter (THO0-4) go to the multiplexer, which selects the desired palette index.

## Sprite 0 Hit

Sprite 0 Hit is an alien PPU feature.

This feature is designed to detect when sprite #0 has "crossed over" to the background.

This event is stored as a bit of register $2002\[6\].

This feature can be used by the programmer to determine when a certain point on the screen is rendered:
- Sprite #0 is set to a certain position
- Polling of the register bit is performed ($2002\[6\])
- The program performs additional actions when Sprite 0 Hit is detected.

This is usually used to create "Split Screen" effects.

Sprite 0 Hit circuit:

![spr0_hit_logic](/BreakingNESWiki/imgstore/ppu/spr0_hit_logic.jpg)

The control output `STRIKE` is 1 only when BGC0=1 or BGC1=1 with all other inputs set to 0.

The control signal `/SPR0HIT` comes from the sprite priority control circuit (see [OAM FIFO](#oam-fifo)) and the control signal `/SPR0_EV` from [sprite comparison circuit](#sprite-comparison-oam-evaluation).

## Multiplexer Tricks

Knowing the features of the multiplexer, you can exploit them to obtain various visual effects.

### Direct Color Mode

This trick is only applicable with PPU rendering turned off (OAM/Background = OFF).

In this mode, the PPU gets the palette index from the TH counter as described above, so by writing to the PPU address space at addresses $3Fxx (where xx = 0x00 ... 0x1F) you can trick the PPU into showing the palette color with the specified index.
(In fact, you don't even have to do a read/write of the palette memory byte, just set the PPU address with register $2006 so that its low-order part is stored in the TH counter).

This technique is demonstrated in the `Full palette demo` (by Blargg): https://wiki.nesdev.org/w/index.php/Full_palette_demo

There it is also stated that the speed of the NES CPU is not sufficient to simulate full bitmap graphics (1 CPU cycle corresponds to 3 PPU "pixels")

### Exploiting EXT Pins

The value from the EXT pins can be used as another color source. But since these pins are usually connected to GND you can only get a black color from them, which can be used to erase the screen with arbitrary patterns.

To do this, you need to program the PPU to Slave mode ($2000\[6\] = 0) when the H/V PPU counters are at the desired location on the screen.

This technique has not yet been confirmed experimentally and exists only as a hypothesis.

# OAM

![ppu_locator_oam](/BreakingNESWiki/imgstore/ppu/ppu_locator_oam.jpg)

Sprite memory (OAM, Object Attribute Memory) takes up almost a quarter of the PPU's area, which was a luxury in those days. The size of the OAM is 2112 bits, of which 1856 are used to store 64 sprites (29 bits per sprite) and the remaining 256 bits are used in a special way to sample the 8 current sprites to be shown on the current line. This area of the OAM is usually called "temporary OAM" or OAM2.

Сombined image of the memory cell topology:

![ppu_oam_closeup](/BreakingNESWiki/imgstore/ppu/ppu_oam_closeup.jpg)

OAM components:
- Memory Cell Array (2112 cells)
- Column Decoder
- Row Decoder
- OAM Buffer control circuit
- OAM Buffer (OB)

![OAM_All](/BreakingNESWiki/imgstore/ppu/OAM_All.png)

Signals table:

|Signal/group|Description|
|---|---|
|**OAM Address**||
|/OAM0-7|Address of the main OAM (in inverse logic)|
|OAM8|1: Use Temp OAM|
|**FSM**||
|BLNK|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|I/OAM2|"Init OAM2". Initialize an additional (temp) OAM|
|/VIS|"Not Visible". The invisible part of the signal (used in sprite logic)|
|**From the sprite comparison**||
|SPR_OV|Sprite Overflow|
|OAMCTR2|OAM Buffer Control|
|**CPU I/F**||
|/R4|0: Read $2004|
|/W4|0: Write $2004|
|/DBE|0: "Data Bus Enable", enable CPU interface|
|**Internal signals**||
|COL0-7|Defines the column to access the main OAM|
|COLZ|Defines the column to access the Temp OAM|
|ROW0-31|Determines the row number. During PCLK all ROW outputs are 0.|
|OB/OAM|1: Write the current value of OB to the output latch|
|/WE|0: write to the selected OAM cell the value from the output latch|
|**Output signals**||
|OFETCH|"OAM Fetch"|
|OB0-7|Current OAM Buffer value (from OB_FF)|

## OAM Layout

By convention, groups of cells that are addressed by the lowest bits of the address will be considered "columns" (bit lines), and groups of cells that are addressed by the highest bits will be considered "rows" (word lines).

- /OAM0-2: Define a column (with a small feature, see below)
- /OAM3-7: Define the row

Additionally, you can see the OAM cell allocation map here: https://github.com/ogamespec/OAMMap

## Memory Cell

|![oam_cell_topo](/BreakingNESWiki/imgstore/ppu/oam_cell_topo.png)|![oam_cell_tran2](/BreakingNESWiki/imgstore/ppu/oam_cell_tran2.png)|![oam_cell](/BreakingNESWiki/imgstore/ppu/oam_cell.jpg)|
|---|---|---|

An OAM cell is a typical 4T-DRAM cell; its value is stored as parasitic capacitance on the gates of two ring-connected transistors, so the value on the cell is constantly degrading. This value enters and exits as the complement (BL + BLBar) when the corresponding word line is selected.

The OAM memory degradation effect is called "OAM Decay" and it is widely known. To combat this effect, programs for the NES contain an OAM cache in regular CPU memory (usually at $200 address) and every VBlank copies this cache to OAM using the APU's sprite DMA.

OAM refresh occurs in two steps, during the precharge process:
- PCLK=1: charge is pumped into the OAM, with all cells "closed"
- PCLK=0: pumped charge is applied to the selected word line cells, updating their value.
If no word line is selected for a long time, the precharge process will not correctly update the word cells, and the cells will begin to degrade (the "OAM Decay" effect).

TBD: Calculate or measure cell degradation timings.

![OAM](/BreakingNESWiki/imgstore/ppu/OAM.png)

![OAM_Lane](/BreakingNESWiki/imgstore/ppu/OAM_Lane.png)

## Column Decoder

![oam_col_decoder](/BreakingNESWiki/imgstore/ppu/oam_col_decoder.jpg)

The circuit is a 1-of-n decoder.

|COL outputs for OAM Buffer bits 0, 1, 5-7|COL outputs for OAM Buffer bits 2-4|
|---|---|
|![oam_col_outputs1](/BreakingNESWiki/imgstore/ppu/oam_col_outputs1.jpg)|![oam_col_outputs2](/BreakingNESWiki/imgstore/ppu/oam_col_outputs2.jpg)|

The skipping of bit lines (columns) at bits 2-4 is done to save memory. If we match the OAM address with the COL values, which are obtained from the lowest bits, we get the following:

```
OamAddr: 0, col: 0
OamAddr: 1, col: 1
OamAddr: 2, col: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 3, col: 3
OamAddr: 4, col: 4
OamAddr: 5, col: 5
OamAddr: 6, col: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 7, col: 7
OamAddr: 8, col: 0
OamAddr: 9, col: 1
OamAddr: 10, col: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 11, col: 3
OamAddr: 12, col: 4
OamAddr: 13, col: 5
OamAddr: 14, col: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 15, col: 7
...
```

As you can see COL2 and COL6 fall just on the attribute byte of the sprite, which does not use bits 2-4.

For Temp OAM skipping of bits is not performed in order not to complicate the already complicated circuitry.

## Row Decoder

![oam_row_decoder](/BreakingNESWiki/imgstore/ppu/oam_row_decoder.jpg)

The circuit is a 1-of-n decoder.

The decoder is designed so that the rows are numbered from right to left (0-31). But due to the fact that in NTSC PPU the OAM address is given in inverted form (/OAM0-7) - logical numbering of rows is mixed up. The result is as follows:

|Row number (topological)|NTSC PPU row number (logical)|
|---|---|
|31|111 11|
|30|011 11|
|29|101 11|
|28|001 11|
|27|110 11|
|26|010 11|
|25|100 11|
|24|000 11|
|23-16|XXX 01|
|15-8|XXX 10|
|7-0|XXX 00|

Or if in order from right to left, grouped into 4 groups:
```
0 16 8 24 4 20 12 28
1 17 9 25 5 21 13 29
2 18 10 26 6 22 14 30
3 19 11 27 7 23 15 31
```

In PAL PPU the numbering corresponds to the sequence 0-31 as designed by the decoder, from right to left, due to the fact that the OAM address is fed in forward logic (`OAM0-7`).

During PCLK = 1 all ROW outputs are 0, i.e. access to all OAM cells is closed.

## Address Decoder

General schematic of the column/row decoder:

![OAM_AddressDecoder](/BreakingNESWiki/imgstore/ppu/OAM_AddressDecoder.png)

## OAM Buffer Control

The circuit is used to set the operating modes of the OB and to control the transfer of values between it and the OAM.

![oam_buffer_control](/BreakingNESWiki/imgstore/ppu/oam_buffer_control.jpg)

![OAM_Control](/BreakingNESWiki/imgstore/ppu/OAM_Control.png)

## OAM Buffer (OB)

The OAM Buffer is used as a transfer point to store a byte that needs to be written to the OAM or a byte that has been read from the OAM for consumers.

The circuit consists of 8 identical circuits for each bit:

![oam_buffer_bit](/BreakingNESWiki/imgstore/ppu/oam_buffer_bit.jpg)

(The picture shows the circuit for storing the OB0 bit).

![OAM_Buffer](/BreakingNESWiki/imgstore/ppu/OAM_Buffer.png)

![OAM_BufferBit](/BreakingNESWiki/imgstore/ppu/OAM_BufferBit.png)

The OB bit circuit is very difficult to understand even for experienced circuit designers, because it is very confusing, besides it deals with Tri-State logic (in Verilog terms - `inout`), which is related to the access to OAM Cells.

Here are the distinctive features of the OB:
- The circuit contains 2 FFs and 2 latches
- `Input_FF` is used to load a value from the OAM Cell and is needed to "secure" the rest of the circuit from `z` values that may be on the cell. During PCLK = 1 this FF is cleared (simultaneously with OAM Precharge)
- `OB_FF` stores the last current value of the OAM Buffer. From these FFs, the OB0-7 signal values are output to the outside. FF is opened during PCLK = 0.
- The `R4 latch` is used for CPU I/F. It stores the value to read register $2004. The latch opens during PCLK = 1.
- The output latch (`out_latch`) is used to write a new value to the OAM Cell. The new value can come from OB_FF (`OB/OAM` = 1) or from the data bus (`BLNK` = 1). The `OB/OAM` and `BLNK` signals never take the value `1` at the same time, but can take the value `0` at the same time (that is, when the output latch is closed).
- The value from the output latch is stored in the selected OAM Cell only when allowed by the `/WE` = 0 signal.

# OAM FIFO

![ppu_locator_fifo](/BreakingNESWiki/imgstore/ppu/ppu_locator_fifo.jpg)

The sprite FIFO is used to temporarily store up to 8 sprites that hit the current row.

It doesn't actually store the entire sprite, but only one line (8 pixels), the priority bit and 2 palette selection bits (attributes) and the X-coordinate.

Note on the term "FIFO": in fact, this component is not explicitly called that anywhere, but the authors considered it convenient to use this term in the perspective of the order in which sprites are displayed on the screen. The PPU patent refers to this circuit as `Motion picture buffer memory`.

![FIFO_All](/BreakingNESWiki/imgstore/ppu/FIFO_All.png)

(open the picture in a new tab for a full view)

Signal table:

|Signal/group of signals|Description|
|---|---|
|**Delayed values of H**||
|H0'' - H2''|Used to obtain /SHx signals|
|H3'' - H5''|Used to select the lane|
|**FSM**||
|PAR/O|"PAR for Object". Selecting a tile for an object (sprite)|
|0/HPOS|"Clear HPos". Clear the H counters in the sprite FIFO and start the FIFO|
|/VIS|"Not Visible". The invisible part of the signal (used in sprite logic)|
|CLPO|1: Clip sprites|
|**From the sprite comparison**||
|PD/FIFO|To zero the output of the H. Inv circuit|
|**Internal signals**||
|/SH2|0: Load sprite attribute|
|/SH3|0: Load sprite X position into the reverse counter|
|/SH5|0: Load `A` byte of the sprite into the paired shift register|
|/SH7|0: Load `B` byte of the sprite into the paired shift register|
|/Tx|The result of the H.INV circuit, the input value to load into the paired shift register (in inverse logic)|
|#0/H|Derived signal from 0/HPOS|
|#x/EN|0: The lane is active. Each lane can be activated individually with its own #EN signal.|
|**Output signals**||
|/SH2|Also used in Data Reader|
|/SPR0HIT|To detect a `Sprite 0 Hit` event|
|#ZCOL0, #ZCOL1, ZCOL2, ZCOL3, #ZPRIO|FIFO results for the multiplexer (MUX)|

## Principle of Operation

FIFO consists of 8 "lanes". Each lane consists of 3 parts: the pixel down-counter, the sprite attributes and the paired shift register.

The down-counter is loaded by the horizontal offset of the sprite and counts down to 0 at the same time as the pixels are rendered. Once the counter reaches 0, it means that you can start rendering the pixels of the sprite.

The attributes store 2 bits of sprite palette selection and 1 bit of priority over the background. These values are used for the entire output line.

The shift register is used to "push out" the next pixel in the sprite. It is paired because 2 bits of color are used for the pixel.

The sprite FIFO is loaded from the special temporary OAM memory (the one which is 32 bytes), during the horizontal synchronization (HBlank).

The schematics show only the lane for sprite #0. All other lanes differ only in the name of the signals.

![FIFO_Lane](/BreakingNESWiki/imgstore/ppu/FIFO_Lane.png)

## Down Counter Control

The circuit shown is for sprite #0. For all others (1-7) you must replace the name of the #0/EN signals with #x/EN.

![fifo_counter_control](/BreakingNESWiki/imgstore/ppu/fifo_counter_control.jpg)

![FIFO_CounterControl](/BreakingNESWiki/imgstore/ppu/FIFO_CounterControl.png)

## Down Counter

![fifo_counter](/BreakingNESWiki/imgstore/ppu/fifo_counter.jpg)

![FIFO_CounterBit](/BreakingNESWiki/imgstore/ppu/FIFO_CounterBit.png)

![FIFO_DownCounter](/BreakingNESWiki/imgstore/ppu/FIFO_DownCounter.png)

## Lane Control

The circuit for sprite #0 is shown. For all others (1-7) the signal names #0/EN, 0/COL2, 0/COL3 and 0/PRIO must be changed to #x/EN, x/COL2, x/COL3 and x/PRIO.

In addition, the H3'', H4'' and H5'' signals are used as 3-on-8 decoder inputs, "spread out" over all the lanes, to select the appropriate lanes:

|Sprite number (lane)|Signal logic H3'', H4'' and H5''|
|---|---|
|0|H3'' H4'' H5''| 
|1|/H3'' H4'' H5''|
|2|H3'' /H4'' H5''|
|3|/H3'' /H4'' H5''|
|4|H3'' H4'' /H5''|
|5|/H3'' H4'' /H5''|
|6|H3'' /H4'' /H5''|
|7|/H3'' /H4'' /H5''|

![fifo_attr](/BreakingNESWiki/imgstore/ppu/fifo_attr.jpg)

![FIFO_LaneControl](/BreakingNESWiki/imgstore/ppu/FIFO_LaneControl.png)

## Paired Shift Register

The circuit shown is for sprite #0. For all others (1-7) you must replace the signal names #0/COL0 and #0/COL1 with #x/COL0 and #x/COL1.

![fifo_sr](/BreakingNESWiki/imgstore/ppu/fifo_sr.jpg)

![FIFO_SRBit](/BreakingNESWiki/imgstore/ppu/FIFO_SRBit.png)

![FIFO_PairedSR](/BreakingNESWiki/imgstore/ppu/FIFO_PairedSR.png)

(open the picture in a new tab for a full view)

:warning: The value is fed to SR8 in reversed form, because the pixels are output backwards.

## Sprite Priority

The priority circuit is in "sparse" layout. The individual pieces of this circuit are shown below.
The circuit is a priority encoder.

![fifo_prio0](/BreakingNESWiki/imgstore/ppu/fifo_prio0.jpg)

![fifo_prio1](/BreakingNESWiki/imgstore/ppu/fifo_prio1.jpg)

![fifo_prio2](/BreakingNESWiki/imgstore/ppu/fifo_prio2.jpg)

![fifo_prio3](/BreakingNESWiki/imgstore/ppu/fifo_prio3.jpg)

![fifo_prio4](/BreakingNESWiki/imgstore/ppu/fifo_prio4.jpg)

The result of the circuit operation (output) is the `/SPR0HIT` signal, which goes to the corresponding Sprite 0 Hit circuit (see [multiplexer](#multiplexer))

![FIFO_Priority](/BreakingNESWiki/imgstore/ppu/FIFO_Priority.png)

(open the picture in a new tab for a full view)

## H. Inversion

![hinv](/BreakingNESWiki/imgstore/ppu/hinv.jpg)

HINV and HDIR are two complementary signals (they can never take the same value). Essentially these two signals are one multiplexer control signal which selects how the PD bus bits are output. If HINV = 1 this means that the PD bus bits are output in reverse order to the `/T0-7` outputs. If HDIR = 1 it means that the PD bus bits are output in straight order on the `/T0-7` outputs.

![H_Inversion](/BreakingNESWiki/imgstore/ppu/H_Inversion.png)

## Sprite H

It was also decided to include a small circuit for getting `/SHx` values (Sprite H) as part of the FIFO. The circuit is above the multiplexer, but most of the `/SHx` outputs are used only in the OAM FIFO (`/SH2` is also used in the Data Reader).

![sprite_h](/BreakingNESWiki/imgstore/ppu/sprite_h.jpg)

![SpriteH](/BreakingNESWiki/imgstore/ppu/SpriteH.png)

# Data Reader

The PPU patent refers to this circuit as the `Still Picture Generator`.

The circuitry takes up almost a quarter of the PPU area and is located in the lower right corner of the chip:

![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/ppu_locator_dataread.jpg)

This circuit deals with sampling a row of 8 pixels, based on the scroll registers which set the position of the tile in the name table and the fine offset of the starting point within the tile.
The results (the current pixel of the tile) are sent to the multiplexer, to mix with the current pixel of the sprite.

The circuit also deals with getting sprite patterns and their V inversion (the H inversion circuit is in [OAM FIFO](#oam-fifo)).

Due to the large size, it will be difficult to show the entire diagram, so naturally we will saw it into its component parts.

Below is shown what circuits the Data Reader consists of, in order to understand where to look for the sawn pieces of circuits:

![ppu_dataread_sections](/BreakingNESWiki/imgstore/ppu/ppu_dataread_sections.jpg)

There was something in this section historically, but then it was split up into sections. The only thing left is the circuit for the generation of the tile address.

![DataReader_All](/BreakingNESWiki/imgstore/ppu/DataReader_All.png)

## Pattern Address Generator

The circuit takes up the whole upper part and forms the tile (`Pattern`) address, which is set by `/PAD0-12` (13 bits).

![patgen_high](/BreakingNESWiki/imgstore/ppu/patgen_high.jpg)

![patgen_vinv](/BreakingNESWiki/imgstore/ppu/patgen_vinv.jpg)

![PatGen](/BreakingNESWiki/imgstore/ppu/PatGen.png)

Small circuits to control the loading of values into the output latches. The main emphasis is on selecting the mode of operation for sprites/backgrounds (signal `PAR/O` - "PAR for Objects").

|![PatControl](/BreakingNESWiki/imgstore/ppu/PatControl.png)|![PatV_Inversion](/BreakingNESWiki/imgstore/ppu/PatV_Inversion.png)|
|---|---|

Bit circuits to form the output value `/PAD0-12` in slight variations:

![PatBit](/BreakingNESWiki/imgstore/ppu/PatBit.png)

![PatBit4](/BreakingNESWiki/imgstore/ppu/PatBit4.png)

![PatBitInv](/BreakingNESWiki/imgstore/ppu/PatBitInv.png)

Table of bits usage in addressing:

|Bit number|Source for BG|Source for OB (sprites 8x8)|Source for OB (sprites 8x16)|Role in addressing|
|---|---|---|---|---|
|0-2|Counter FV0-2|Sprite comparison OV0-2|Sprite comparison OV0-2|Pattern line number|
|3|/H1' Signal|/H1' Signal|/H1' Signal|A/B byte of the pattern line|
|4|Name Table, bit 0|OAM2, Tile Index Byte, bit 0|Sprite comparison OV3|Index in Pattern Table|
|5-11|Name Table, bits 1-7|OAM2, Tile Index Byte, bits 1-7|OAM2, Tile Index Byte, bits 1-7|Index in Pattern Table|
|12|BGSEL ($2000)|OBSEL ($2000)|OAM2, Tile Index Byte, bit 0|Selecting Pattern Table|

## The Rest

The other parts of the schematic can be found in the corresponding sections:

- [Scrolling Registers](#scroll-registers)
- [Picture Address Register](#picture-address-register)
- [Background Color](#background-color-bg-col)

# Scroll Registers

![ppu_locator_scroll_regs](/BreakingNESWiki/imgstore/ppu/ppu_locator_scroll_regs.jpg)

The scrolling registers are tricky:
- Two consecutive writes to $2005 or $2006 put values into the same FF
- The best way to see when and where they are written is in the tables below
- The Name Table also uses a similar duality when writing to the $2000 register

Anyone who has been programming NES for a long time is familiar with these features. They are usually referred to in the context of `loopy`, by the nickname of the person who reviewed their features for emulation purposes.

Who is just starting to get familiar with the NES, it's ... arrgh...

![SCC_Regs](/BreakingNESWiki/imgstore/ppu/SCC_Regs.png)

FF circuit used to store values:

![SCC_FF](/BreakingNESWiki/imgstore/ppu/SCC_FF.png)

## Fine HScroll

![dualregs_fh](/BreakingNESWiki/imgstore/ppu/dualregs_fh.jpg)

![SCC_FineH](/BreakingNESWiki/imgstore/ppu/SCC_FineH.png)

|W5/1|FH|
|---|---|
|DB0|0|
|DB1|1|
|DB2|2|

## Fine VScroll

![dualregs_fv](/BreakingNESWiki/imgstore/ppu/dualregs_fv.jpg)

![SCC_FineV](/BreakingNESWiki/imgstore/ppu/SCC_FineV.png)

|W5/2|W6/1|FV|
|---|---|---|
|DB0|DB4|0|
|DB1|DB5|1|
|DB2|`0`|2|

Writing `0` to FV2 instead of $2006\[6\] is because the value for the FV counter is forcibly limited to the range 0-3, because otherwise its value would be outside the PPU address space.

## Name Table Select

![dualregs_nt](/BreakingNESWiki/imgstore/ppu/dualregs_nt.jpg)

![SCC_NTSelect](/BreakingNESWiki/imgstore/ppu/SCC_NTSelect.png)

|W0|W6/1|NT|
|---|---|---|
|DB0|DB2|NTH|
|DB1|DB3|NTV|

## Tile V

![dualregs_tv](/BreakingNESWiki/imgstore/ppu/dualregs_tv.jpg)

![SCC_TileV](/BreakingNESWiki/imgstore/ppu/SCC_TileV.png)

|W5/2|W6/1|W6/2|TV|
|---|---|---|---|
|DB3| |DB5|0|
|DB4| |DB6|1|
|DB5| |DB7|2|
|DB6|DB0| |3|
|DB7|DB1| |4|

## Tile H

![dualregs_th](/BreakingNESWiki/imgstore/ppu/dualregs_th.jpg)

![SCC_TileH](/BreakingNESWiki/imgstore/ppu/SCC_TileH.png)

|W5/1|W6/2|TH|
|---|---|---|
|DB3|DB0|0|
|DB4|DB1|1|
|DB5|DB2|2|
|DB6|DB3|3|
|DB7|DB4|4|

# Picture Address Register

![ppu_locator_par](/BreakingNESWiki/imgstore/ppu/ppu_locator_par.jpg)

![PAR_All](/BreakingNESWiki/imgstore/ppu/PAR_All.png)

The PAR address register stores the value for the external address bus (`/PA0-13`) (14 bit).

Sources for writing to the PAR:
- A pattern address (`PAD0-12`) (13 bit)
- The value from the data bus (`DB0-7`) (8 bit)
- The value from the PAR counters which are also part of this circuit. The PAR counters are loaded from the scrolling registers.

## PAR Counters

Counter operating modes:

|Counter|Bits|Max value|Max value (Blank)|Input carry source|Input carry source (Blank)|Counter reset source|Carry output|Carry output (Blank)|
|---|---|---|---|---|---|---|---|---|
|Tile Horizontal|5	|32	|32	|!(BLNK & I1/32)		|!(BLNK & I1/32)		|none					|yes	|yes|
|Tile Vertical	|5	|30	|32	|Fine Vertical CNT		|Tile Horizontal CNT	|carry TVZ + 1 TVSTEP	|yes	|yes|
|Name Table H	|1	|2	|2	|Tile Horizontal CNT	|Tile Vertical CNT		|none					|no		|yes|
|Name Table V	|1	|2	|2	|Tile Vertical CNT		|Name Table H  CNT		|none					|no		|yes|
|Fine Vertical	|3	|8	|8	|Tile Horizontal CNT	|Name Table V  CNT		|none					|yes	|no|

### PAR Counters Control

![ppu_dataread_par_counters_control_top](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_top.jpg)

![ppu_dataread_par_counters_control_bot](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_bot.jpg)

![PAR_CountersControl](/BreakingNESWiki/imgstore/ppu/PAR_CountersControl.png)

![PAR_CountersControl2](/BreakingNESWiki/imgstore/ppu/PAR_CountersControl2.png)

### Counter Bit

![PAR_CounterBit](/BreakingNESWiki/imgstore/ppu/PAR_CounterBit.png)

A reset variation is used for the TV counter:

![PAR_CounterBitReset](/BreakingNESWiki/imgstore/ppu/PAR_CounterBitReset.png)

### FV Counter

![ppu_dataread_par_counters_fv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_fv.jpg)

![PAR_FVCounter](/BreakingNESWiki/imgstore/ppu/PAR_FVCounter.png)

### NT Counters

![ppu_dataread_par_counters_nt](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_nt.jpg)

![PAR_NTCounters](/BreakingNESWiki/imgstore/ppu/PAR_NTCounters.png)

### TV Counter

![ppu_dataread_par_counters_tv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_tv.jpg)

![PAR_TVCounter](/BreakingNESWiki/imgstore/ppu/PAR_TVCounter.png)

Note the tricky `0/TV` signal. This signal clears not only the contents of the counter's input FF on the Keep phase, but also makes a pulldown on its output value, but NOT the complementary output.

### TH Counter

![ppu_dataread_par_counters_th](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_th.jpg)

![PAR_THCounter](/BreakingNESWiki/imgstore/ppu/PAR_THCounter.png)

## PAR

![PAR](/BreakingNESWiki/imgstore/ppu/PAR.png)

The circuit looks a bit scary, this is because of the large number of input sources to load into the PAR register bits.

### PAR Control

The control circuit is designed to select one of the sources for writing to PAR.

![ppu_dataread_par_control](/BreakingNESWiki/imgstore/ppu/ppu_par_control.jpg)

![PAR_Control](/BreakingNESWiki/imgstore/ppu/PAR_Control.png)

### PAR Outputs

![ppu_dataread_par_low](/BreakingNESWiki/imgstore/ppu/ppu_par_low.jpg)

![ppu_dataread_par_high](/BreakingNESWiki/imgstore/ppu/ppu_par_high.jpg)

![PAR_LowBit](/BreakingNESWiki/imgstore/ppu/PAR_LowBit.png)

![PAR_HighBit](/BreakingNESWiki/imgstore/ppu/PAR_HighBit.png)

# Background Color (BG COL)

![ppu_locator_bgcol](/BreakingNESWiki/imgstore/ppu/ppu_locator_bgcol.jpg)

![BGC_All](/BreakingNESWiki/imgstore/ppu/BGC_All.png)

## BG COL Circuit Control

|![ppu_dataread_bgcol_control_left](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgcol_control_left.jpg)|![ppu_dataread_bgcol_control_right](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgcol_control_right.jpg)|
|---|---|

![BGC_Control](/BreakingNESWiki/imgstore/ppu/BGC_Control.png)

## Shift Register (SR8)

![BGC_SRBit](/BreakingNESWiki/imgstore/ppu/BGC_SRBit.png)

![BGC_SR8](/BreakingNESWiki/imgstore/ppu/BGC_SR8.png)

## Obtaining BGC0

![ppu_dataread_bgc0](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgc0.jpg)

![BGC_0](/BreakingNESWiki/imgstore/ppu/BGC_0.png)

:warning: The value is fed to SR8 in reversed form, because the pixels are output backwards.

## Obtaining BGC1

![ppu_dataread_bgc1](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgc1.jpg)

![BGC_1](/BreakingNESWiki/imgstore/ppu/BGC_1.png)

:warning: The value is fed to SR8 in reversed form, because the pixels are output backwards.

## Obtaining BGC2

![ppu_dataread_bgc2](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgc2.jpg)

![BGC_2](/BreakingNESWiki/imgstore/ppu/BGC_2.png)

## Obtaining BGC3

![ppu_dataread_bgc3](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgc3.jpg)

![BGC_3](/BreakingNESWiki/imgstore/ppu/BGC_3.png)

## BG COL Outputs

![ppu_dataread_bgcol_out](/BreakingNESWiki/imgstore/ppu/ppu_dataread_bgcol_out.jpg)

![BGC_Out](/BreakingNESWiki/imgstore/ppu/BGC_Out.png)

# VRAM Controller

![ppu_locator_vram_ctrl](/BreakingNESWiki/imgstore/ppu/ppu_locator_vram_ctrl.jpg)

The circuitry is the "auxiliary brain" of the bottom of the PPU to control the VRAM interface.

In addition, the controller also includes a READ BUFFER (RB), an intermediate data storage for exchange with VRAM.

## Transistor Circuit

<img src="/BreakingNESWiki/imgstore/ppu/vram_control_tran.jpg" width="1000px">

Anatomically the circuit is divided into 2 large halves, the left one is more connected to the `WR` control signal and the right one to the `RD`.
Each half includes an RS trigger and a delay line that automatically resets the trigger.

The circuit outputs a number of control lines to the outside:
- RD: to /RD output
- WR: to /WR output
- /ALE: to the ALE output (ALE=1 when the AD bus works as an address bus, ALE=0 when AD works as a data bus)
- TSTEP: to the DATAREAD circuit, allows TV/TH counters to perform incremental
- DB/PAR: on the DATAREAD circuit, connects the internal PPU DB bus to the PAR (PPU address register) pseudo register
- PD/RB: connects the external PPU bus to a read buffer to load a new value into it
- TH/MUX: send the TH counter to the MUX input, causing this value to go into the palette as an index.
- XRB: enable tri-state logic that disconnects the PPU read buffer from the internal data bus.

## Logic

![vram_control_logisim](/BreakingNESWiki/imgstore/ppu/vram_control_logisim.jpg)

## Read Buffer (RB)

Located to the right of [OAM FIFO](#oam-fifo). Read Buffer is associated with register $2007.

|Transistor circuit|Logic circuit|
|---|---|
|![readbuffer_tran](/BreakingNESWiki/imgstore/ppu/readbuffer_tran.jpg)|![readbuffer_logisim](/BreakingNESWiki/imgstore/ppu/readbuffer_logisim.jpg)|

# Wiring

This section contains a summary table of all signals.

If a signal is repeated somewhere, it is usually not specified again, except in cases where it is important.

The signals for the PAL version of the PPU are marked in the pictures only where there are differences from NTSC.

The most important control signals of the [PPU FSM](#ppu-fsm) are marked with a special icon (:zap:).

## Left Side

![ppu_locator_rails_left](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_left.jpg)

|NTSC|PAL|
|---|---|
|![ntsc_rails1](/BreakingNESWiki/imgstore/ppu/ntsc_rails1.jpg)|![pal_rails1](/BreakingNESWiki/imgstore/ppu/pal_rails1.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PCLK|PCLK Gen|All|The PPU is in the PCLK=1 state|
|/PCLK|PCLK Gen|All|The PPU is in the PCLK=0 state|
|RC|/RES Pad|Regs|"Registers Clear"|
|EXT0-3 IN|EXT Pads|MUX|Input subcolor from Master PPU|
|/EXT0-3 OUT|EXT Pads|MUX|Output color for Slave PPU|
|/SLAVE|Regs $2000\[6\]|EXT Pads|PPU operating mode (Master/Slave)|
|R/W|R/W Pad|RW Decoder, Reg Select|CPU interface operating mode (read/write)|
|/DBE|/DBE Pad|Regs|"Data Bus Enable", enable CPU interface|
|RS0-3|RS Pads|Reg Select|Selecting a register for the CPU interface|
|/W6/1|Reg Select| |First write to $2006|
|/W6/2|Reg Select| |Second write to $2006|
|/W5/1|Reg Select| |First write to $2005|
|/W5/2|Reg Select| |Second write to $2005|
|/R7|Reg Select| |Read $2007|
|/W7|Reg Select| |Write $2007|
|/W4|Reg Select| |Write $2004|
|/W3|Reg Select| |Write $2003|
|/R2|Reg Select| |Read $2002|
|/W1|Reg Select| |Write $2001|
|/W0|Reg Select| |Write $2000|
|/R4|Reg Select| |Read $2004|
|V0-7|VCounter|Sprite Compare, Sprite Eval|The V counter bits. Bit V7 additionally goes into the Sprite Eval logic.|
|:zap:RESCL (VCLR)|FSM|All|"Reset FF Clear" / "VBlank Clear". VBlank period end event. Initially the connection was established with contact /RES, but then it turned out a more global purpose of the signal. Therefore, the signal has two names.|
|OMFG|Sprite Eval|OAM Counters Ctrl|TBD: Control signal|
|:zap:BLNK|FSM|HDecoder, All|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|:zap:PAR/O|FSM|All|"PAR for Object". Selecting a tile for an object (sprite)|
|ASAP|OAM Counters Ctrl|OAM Counters Ctrl|TBD: Control signal|
|:zap:/VIS|FSM|Sprite Logic|"Not Visible". The invisible part of the signal (used in sprite logic)|
|:zap:I/OAM2|FSM|Sprite Logic|"Init OAM2". Initialize an additional (temp) OAM|
|/H2'|HCounter|All|H2 signal delayed by one DLatch (in inverse logic)|
|SPR_OV|OAM Counters Ctrl|Sprite Eval|Sprites on the current line are more than 8 or the main OAM counter is full, copying is stopped|
|:zap:/EVAL|FSM|Sprite Logic|0: "Sprite Evaluation in Progress"|
|H0'|HCounter|All|H0 signal delayed by one DLatch|
|EvenOddOut|Even/Odd Circuit|OAM Counters Ctrl|:warning: Only for PAL PPU.|

|NTSC|PAL|
|---|---|
|![ntsc_rails2](/BreakingNESWiki/imgstore/ppu/ntsc_rails2.jpg)|![pal_rails2](/BreakingNESWiki/imgstore/ppu/pal_rails2.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|:zap:E/EV|FSM|Sprite Logic|"End Sprite Evaluation"|
|:zap:S/EV|FSM|Sprite Logic|"Start Sprite Evaluation"|
|/H1'|HCounter|All|H1 signal delayed by one DLatch (in inverse logic)|
|/H2'|HCounter|All|H2 signal delayed by one DLatch (in inverse logic)|
|:zap:/FO|FSM|Data Reader|"Fetch Output Enable"|
|:zap:F/AT|FSM|Data Reader|"Fetch Attribute Table"|
|:zap:#F/NT|FSM|Data Reader, OAM Eval|0: "Fetch Name Table"|
|:zap:F/TA|FSM|Data Reader|"Fetch Tile A"|
|:zap:F/TB|FSM|Data Reader|"Fetch Tile B"|
|:zap:CLIP_O|FSM|Control Regs|"Clip Objects". 1: Do not show the left 8 screen points for sprites. Used to get the `CLPO` signal that goes into the OAM FIFO.|
|:zap:CLIP_B|FSM|Control Regs|"Clip Background". 1: Do not show the left 8 points of the screen for the background. Used to get the `/CLPB` signal that goes into the Data Reader.|
|VBL|Regs $2000\[7\]|FSM|Used in the VBlank interrupt handling circuitry|
|/TB|Regs $2001\[7\]|VideoOut|"Tint Blue". Modifying value for Emphasis|
|/TG|Regs $2001\[6\]|VideoOut|"Tint Green". Modifying value for Emphasis|
|/TR|Regs $2001\[5\]|VideoOut|"Tint Red". Modifying value for Emphasis|
|:zap:SC/CNT|FSM|Data Reader|"Scroll Counters Control". Update the scrolling registers.|
|:zap:0/HPOS|FSM|OAM FIFO|"Clear HPos". Clear the H counters in the sprite FIFO and start the FIFO|
|/SPR0_EV|Sprite Eval|Spr0 Strike|0: Sprite "0" is found on the current line. To define a `Sprite 0 Hit` event|
|/OBCLIP|Regs $2001\[2\]|FSM|To generate the `CLIP_O` control signal|
|/BGCLIP|Regs $2001\[1\]|FSM|To generate the `CLIP_B` control signal|
|H0'' - H5''|HCounter|All|H0-H5 signals delayed by two DLatch|
|BLACK|Control Regs|FSM|Active when PPU rendering is disabled (see $2001[3] и $2001[4]). :warning: The circuitry for the signal generation is slightly different in the PAL PPU.|
|DB0-7|All|All|Internal data bus DB|
|B/W|Regs $2001\[0\]|Color Buffer|Disable Color Burst, to generate a monochrome picture|
|TH/MUX|VRAM Ctrl|MUX, Color Buffer|Send the TH Counter value to the MUX input, which will cause the value to go into the palette as Direct Color.|
|DB/PAR|VRAM Ctrl|Data Reader, Color Buffer|TBD: Control signal|

|NTSC|PAL|
|---|---|
|![ntsc_rails3](/BreakingNESWiki/imgstore/ppu/ntsc_rails3.jpg)|![pal_rails3](/BreakingNESWiki/imgstore/ppu/pal_rails3.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PAL0-4|MUX|Palette|Palette RAM Address|

## Right Side

![ppu_locator_rails_right](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_right.jpg)

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails4](/BreakingNESWiki/imgstore/ppu/ntsc_rails4.jpg)|
|PAL|![pal_rails4](/BreakingNESWiki/imgstore/ppu/pal_rails4.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/OAM0-2|OAM Counters|OAM|OAM Address. :warning: The NTSC version of the PPU uses values in inverse logic (/OAM0-7). The PAL version of the PPU uses values in forward logic (OAM0-7)|
|OAM8|OAM2 Counter|OAM|Selects an additional (temp) OAM for addressing|

|NTSC|PAL|
|---|---|
|![ntsc_rails5](/BreakingNESWiki/imgstore/ppu/ntsc_rails5.jpg)|![rails5](/BreakingNESWiki/imgstore/ppu/pal_rails5.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/OAM0-7|OAM Counters|OAM|OAM Address. :warning: The NTSC version of the PPU uses values in inverse logic (/OAM0-7). The PAL version of the PPU uses values in forward logic (OAM0-7)|
|OAM8|OAM2 Counter|OAM|Selects an additional (temp) OAM for addressing|
|OAMCTR2|OAM Counters Ctrl|OAM Buffer Ctrl|OAM Buffer Control|
|OB0-7'|OAM Buffer|Sprite Compare|OB output values passed through the PCLK tristates.|

Note: The different inversion of OAM address values of PAL and NTSC PPUs causes the values on the cells in the PAL PPU to be stored in reverse order relative to the NTSC PPU. It does not cause anything else in particular.

|NTSC|PAL|
|---|---|
|![ntsc_rails6](/BreakingNESWiki/imgstore/ppu/ntsc_rails6.jpg)|![rails6](/BreakingNESWiki/imgstore/ppu/pal_rails6.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|OV0-3|Sprite Compare|V Inversion|Bit 0-3 of the V sprite value|
|OB7|OAM Buffer|OAM Eval|OAM Buffer output value, bit 7. For the OAM Eval circuit, this value is exclusively transmitted directly from the OB, without using the PCLK tristate.|
|PD/FIFO|OAM Eval|H Inversion|To zero the output of the H. Inv circuit|
|I1/32|Regs $2000\[2\]|PAR Counters Ctrl|Increment PPU address 1/32. :warning: PAL PPU uses an inverse version of the signal (#I1/32)|
|OBSEL|Regs $2000\[3\]|Pattern Readout|Selecting Pattern Table for sprites|
|BGSEL|Regs $2000\[4\]|Pattern Readout|Selecting Pattern Table for background|
|O8/16|Regs $2000\[5\]|OAM Eval, Pattern Readout|Object lines 8/16 (sprite size). :warning: The PAL PPU uses an inverse version of the signal (#O8/16)|

|NTSC|PAL|
|---|---|
|![ntsc_rails7](/BreakingNESWiki/imgstore/ppu/ntsc_rails7.jpg)|![rails7](/BreakingNESWiki/imgstore/ppu/pal_rails7.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/SH2|Near MUX|OAM FIFO, V. Inversion|Sprite H value bits. /SH2 also goes into V. Inversion.|
|/SH3|Near MUX|OAM FIFO|Sprite H value bits|
|/SH5|Near MUX|OAM FIFO|Sprite H value bits|
|/SH7|Near MUX|OAM FIFO|Sprite H value bits|
|/SPR0HIT|OAM Priority|Spr0 Strike|To detect a `Sprite 0 Hit` event|
|BGC0-3|BG Color|MUX|Background color|
|/ZCOL0, /ZCOL1, ZCOL2, ZCOL3|OAM FIFO|MUX|Sprite color. :warning: The lower 2 bits are in inverse logic, the higher 2 bits are in direct logic.|
|/ZPRIO|OAM Priority|MUX|0: Priority of sprite over background|
|THO0-4'|PAR TH Counter|MUX|THO0-4 value passed through the PCLK tristate. Direct Color value from TH Counter.|

## Bottom Part

![ppu_locator_rails_bottom](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_bottom.jpg)

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails8](/BreakingNESWiki/imgstore/ppu/ntsc_rails8.jpg)|
|PAL|![pal_rails8](/BreakingNESWiki/imgstore/ppu/pal_rails8.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|OB0-7|OAM Buffer|OAM FIFO, Pattern Readout|OAM Buffer output value|
|CLPO|Regs|OAM FIFO|To enable sprite clipping|
|/CLPB|Regs|BG Color|To enable background clipping|
|PD/FIFO|OAM Eval|H Inversion|To zero the output of the H. Inv circuit|
|BGSEL|Regs|Pattern Readout|Selecting Pattern Table for background|
|OV0-3|Sprite Compare|V Inversion|Bit 0-3 of the V sprite value|

|NTSC|PAL|
|---|---|
|![ntsc_rails9](/BreakingNESWiki/imgstore/ppu/ntsc_rails9.jpg)|![pal_rails9](/BreakingNESWiki/imgstore/ppu/pal_rails9.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/PA0-7|PAR|PPU Address|VRAM address bus|
|/PA8-13|PAR|PPU Address, VRAM Ctrl|VRAM address bus|
|THO0-4|PAR TH Counter|BG Color, MUX|Bit 1 of TH Counter is used in the BG Color circuit. THO0-4 is used in the Multiplexer as Direct Color.|
|TSTEP|VRAM Ctrl|PAR Counters Ctrl|For PAR Counters control logic|
|TVO1|PAR TV Counter|BG Color|Bit 1 of TV Counter|
|FH0-2|Scroll Regs|BG Color|Fine H value|

`/PA0-7` are not shown in the picture, they are on the right side of the [PPU address register](#picture-address-register).

|NTSC|PAL|
|---|---|
|![ntsc_rails10](/BreakingNESWiki/imgstore/ppu/ntsc_rails10.jpg)|![pal_rails10](/BreakingNESWiki/imgstore/ppu/pal_rails10.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PD0-7|All Bottom|All Bottom|VRAM data bus, used at the bottom for data transfer. It is associated with the corresponding PPU pins (`AD0-7`).|
|THO1|PAR TH Counter|BG Color|Bit 1 of TH Counter|
|TVO1|PAR TV Counter|BG Color|Bit 1 of TV Counter|
|BGC0-3|BG Color|MUX|Background color|
|FH0-2|Scroll Regs|BG Color|Fine H value|

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails11](/BreakingNESWiki/imgstore/ppu/ntsc_rails11.jpg)|
|PAL|![pal_rails11](/BreakingNESWiki/imgstore/ppu/pal_rails11.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PD/RB|VRAM Ctrl|Read Buffer (RB)|Opens RB input (connect PD and RB).|
|XRB|VRAM Ctrl|Read Buffer (RB)|Opens RB output (connect RB and DB).|
|RD|VRAM Ctrl|Pad|Output value for `/RD` pin|
|WR|VRAM Ctrl|Pad|Output value for `/WR` pin|
|/ALE|VRAM Ctrl|Pad|Output value for `ALE` pin|

# PAL PPU

This section describes the differences in schematics between the PAL PPU version (RP2C07) and the reference NTSC PPU (RP2C02).

## FSM

Found differences from NTSC PPU.

Significantly different EVEN/ODD circuitry (located to the right of the V PLA). The `EvenOddOut` signal goes into sprite logic instead of controlling the H/V counters:

![fsm_even_odd](/BreakingNESWiki/imgstore/ppu/pal/fsm_even_odd.png)

![EvenOdd_PAL](/BreakingNESWiki/imgstore/ppu/pal/EvenOdd_PAL.png)

Slightly different logic for clearing H/V counters:

![fsm_clear_counters](/BreakingNESWiki/imgstore/ppu/pal/fsm_clear_counters.png)

Bit V0 for the phase generator comes out of the VCounter (see VideoOut schematic):

![fsm_v0](/BreakingNESWiki/imgstore/ppu/pal/fsm_v0.png)

BLACK and /PICTURE signals are processed in a special way for PAL (with slight differences):

![fsm_npicture](/BreakingNESWiki/imgstore/ppu/pal/fsm_npicture.png)

Regarding BLACK, see below.

H/V Decoders are also different.

All other parts (Horizontal and vertical FSM logic, register selection circuit, H/V counters) are the same as NTSC PPU.

## H Decoder

![pal_h](/BreakingNESWiki/imgstore/ppu/pal/pal_h.png)

|HPLA output|Pixel numbers of the line|Bitmask|VB Tran|BLNK Tran|Involved|
|---|---|---|---|---|---|
|0|277|01101010011001100100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS|
|6|63|10101001010101010101| |yes|/EVAL|
|7|255|00010101010101010101| |yes|E/EV|
|8|0-63|10101000000000000001| |yes|I/OAM2|
|9|256-319|01101000000000000001| |yes|PAR/O|
|10|0-255|10000000000000000011|yes|yes|/VIS|
|11|Each 0..1|00000000000010100001| |yes|#F/NT|
|12|Each 6..7|00000000000001010000| | |F/TB|
|13|Each 4..5|00000000000001100000| | |F/TA|
|14|320-335|01000110100000000001| |yes|/FO|
|15|0-255|10000000000000000001| |yes|F/AT|
|16|Each 2..3|00000000000010010000| | |F/AT|
|17|256|01101010101010101000| | |BPorch FF|
|18|4|10101010101001101000| | |BPorch FF|
|19|277|01101010011001100100| | |HBlank FF|
|20|302|01101001100101011000| | |HBlank FF|
|21|321|01100110101010100100| | |BURST FF|
|22|306|01101001011010011000| | |BURST FF|
|23|340|01100110011001101000| | |HCounter clear / VCounter step|

## V Decoder

![pal_v](/BreakingNESWiki/imgstore/ppu/pal/pal_v.png)

|VPLA output|Line number|Bitmask|Involved|
|---|---|---|---|
|0|272|011010100110101010|VSYNC FF|
|1|269|011010101001011001|VSYNC FF|
|2|1|101010101010101001|PICTURE FF|
|3|240|000101010110101010|PICTURE FF|
|4|241|000101010110101001|/VSET|
|5|0|101010101010101010|VB FF|
|6|240|000101010110101010|VB FF, BLNK FF|
|7|311|011010010110010101|BLNK FF|
|8|311|011010010110010101|VCLR|
|9|265|011010101001101001|Even/Odd|

## Video Out

CLK:

![vidout_clk](/BreakingNESWiki/imgstore/ppu/pal/vidout_clk.png)

PCLK:

![vidout_pclk](/BreakingNESWiki/imgstore/ppu/pal/vidout_pclk.png)

![pclk_2C07](/BreakingNESWiki/imgstore/ppu/pclk_2C07.jpg)

The color decoder is twice as big (due to the peculiarity of the PAL phase alteration). The V0 bit from the VCounter comes on the decoder to determine the parity of the current line (for phase alteration). The phase shifter is matched to a doubled decoder:

![vidout_phase_chroma](/BreakingNESWiki/imgstore/ppu/pal/vidout_phase_chroma.png)

![vidout_chroma_decoder](/BreakingNESWiki/imgstore/ppu/pal/vidout_chroma_decoder.png)

|Output|Bitmask|
|---|---|
|0|1001100110|
|1|0110100101|
|2|1010100101|
|3|0101100110|
|4|1001010110|
|5|0110011001|
|6|1010011010|
|7|0101011010|
|8|1001101001|
|9|0110101001|
|10|0010101010|
|11|1010100110|
|12|0101101010|
|13|1001011001|
|14|0110010110|
|15|1010010110|
|16|0101011001|
|17|1001101010|
|18|0110100110|
|19|1010101001|
|20|0101101001|
|21|1001011010|
|22|0110011010|
|23|1010011001|
|24|0101010110|

(The numbering of the outputs is topological from left to right. The bit order is top-down. 1 means there is a transistor. 0 means no transistor)

The /PICTURE signal undergoes additional processing (DLATCH delay):

![vidout_npicture](/BreakingNESWiki/imgstore/ppu/pal/vidout_npicture.png)

![nPICTURE_Pal](/BreakingNESWiki/imgstore/ppu/pal/nPICTURE_Pal.png)

The /PICTURE signal comes to the Color Buffer Control circuit in unmodified form (as in NTSC PPU).

Also, the connection in the signal circuitry of /PR and /PG is mixed up, as a result of which the phase adjustment for the red and green channel works vice versa:

![Mixed_RG_Emphasis](/BreakingNESWiki/imgstore/ppu/pal/Mixed_RG_Emphasis.png)

DAC, Emphasis and Luma Decoder circuits are the same as NTSC.

## Regs

The `/SLAVE` signal goes through 2 additional inverters for amplification:

![regs_nslave](/BreakingNESWiki/imgstore/ppu/pal/regs_nslave.png)

The B/W signal goes by roundabout ways through the multiplexer, for this purpose it is amplified by two inverters (which do not reverse the polarity of the signal):

![regs_bw](/BreakingNESWiki/imgstore/ppu/pal/regs_bw.png)

The two signals O8/16 and I1/32 are output in inverse logic (there are additional inverters for them in the Data Reader):

![regs_o816_i132](/BreakingNESWiki/imgstore/ppu/pal/regs_o816_i132.png)

The `BLACK` signal processing logic is screwed on:

![regs_black](/BreakingNESWiki/imgstore/ppu/pal/regs_black.png)

The /BLACK signal comes out of the register block. The FET that acts as a DLatch is in the FSM block. It produces the original BLACK signal.

![BLACK_Pal](/BreakingNESWiki/imgstore/ppu/pal/BLACK_Pal.png)

The output of the VBL control signal is slightly different (an additional cutoff transistor is used which is not present in the NTSC PPU):

![regs_vbl](/BreakingNESWiki/imgstore/ppu/pal/regs_vbl.png)

## Sprite Logic

In general, the differences are minimal, but there are nuances. All differences are marked with an exclamation mark.

No changes were found in the comparator logic.

There is only one small change in the comparison control circuit (the lowest one), related to the fact that the signal O8/16 in PAL PPU is already in inverse logic, so an inverter is not required for it:

![eval_o816](/BreakingNESWiki/imgstore/ppu/pal/eval_o816.png)

The counter digit circuits (OAM Counter and OAM2 Counter) are modified so that there is no inverter on the output. Therefore, the outputs (index to access the OAM memory) are in forward logic (`OAM0-7`) and not in inverse logic as in the NTSC PPU (`/OAM0-7`):

![eval_counters](/BreakingNESWiki/imgstore/ppu/pal/eval_counters.png)

The BLNK signal processing circuit (located just above the OAM2 Counter) is different:

|![eval_blnk](/BreakingNESWiki/imgstore/ppu/pal/eval_blnk.png)|![eval_blnk_analysis](/BreakingNESWiki/imgstore/ppu/pal/eval_blnk_analysis.png)
|---|---|

Most likely this DLatch is used to deal with the unaligned interaction between the CPU/PPU and register $2004.
In simple words: Disabling PPU rendering in 2C07 has the effect of addressing the OAM only to the beginning of the next pixel if it was done to the "second half" of the current pixel.

The control circuit of OAM Counter for the control signal `OMSTEP` is additionally modified by the signal `EvenOddOut`, which comes from the EVEN/ODD circuit (this circuit is to the right of V PLA):

![eval_even_odd](/BreakingNESWiki/imgstore/ppu/pal/eval_even_odd.png)

And the main difference: instead of the usual W3 Enabler, which is used in the NTSC PPU, a whole big circuit is used, which is at the very top, to the left of the RW Decoder. It generates the `W3'` signal similar to the NTSC PPU, but in the PAL PPU it goes through the delay line from the DLatch.

![eval_w3_enable](/BreakingNESWiki/imgstore/ppu/pal/eval_w3_enable.png)

## OAM

Since the OAM address (`OAM0-7`) is issued in direct logic, the outputs of columns 2 and 6 are rearranged for bits 2-4 of the OAM Buffer.

![pal_oam_col_decoder_tran](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_col_decoder_tran.png)

![pal_oam_col_outputs1](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_col_outputs1.png)

(NTSC PPU to the left)

![pal_oam_col_outputs2](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_col_outputs2.png)

(NTSC PPU to the left)

## Data Reader

For the inverse signals `#O8/16` and `#I1/32`, 2 inverters have been added where these signals enter the circuit.

|PAL|NTSC|
|---|---|
|![o816_inv](/BreakingNESWiki/imgstore/ppu/pal/o816_inv.jpg)|![o816_orig](/BreakingNESWiki/imgstore/ppu/pal/o816_orig.jpg)|
|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_inv.jpg)|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_orig.jpg)|

Thus the inverse propagation of these signals from the register block does not introduce any significant impact compared to the NTSC PPU.

## Interconnects

See [Interconnections](#wiring)

## Impact for emulation/simulation

This section is especially for authors of NES emulators.

It is hard to tell how to transfer these changes to your emulator sources, but here are some thoughts:

- You need to tweak the PPU rendering logic in terms of H/V timings, according to the H/V decoder of the PPU. Its output values are in the table, you just need to relate them to what you have for the NTSC PPU
- The PAL PPU has no NTSC Crawl logic and the Even/Odd circuit does completely different things. Its EvenOddOut signal goes into the control logic of the OAM Counter ($2003) and affects its recalculation (OMSTEP signal). You have to figure out by yourself how OMSTEP logic in NTSC PPU differs from PAL PPU, taking into account EvenOddOut signal.
- You also need to consider the write delay in register $2003, which is implemented by the W3 Enabler circuit.

Everything else is probably irrelevant to software emulation.

As for the video output, based on the Phase Shifter circuit and Chroma decoder values, it is now possible to make a filter/shader like the NTSC Filter by blargg. An experienced NES hacker can easily do it here.

# RGB PPU

This section discusses the differences between the RGB PPU RP2C04-0003, and the reference PPU 2C02G.

At the moment, these are the only images of RGB PPU that we have. However, there are pictures of only the top layer, so it is not always good to see what is underneath. Something was partly visible, partly guessed, so here it looks more like a Japanese puzzle.

List of major differences:
- EXT0-3 and VOUT pins are replaced by RED, GREEN, BLUE, /SYNC pins, for component video signal output.
- An RGB encoding circuit is used instead of a composite video generator. DAC with weighted current summation.
- Emphasis applies the corresponding channel output to all one's
- There is no possibility to read OAM (no `/R4` register operation), for this reason the OAM Buffer is arranged simpler
- There is no possibility to read CRAM, for this reason the Color Buffer is simpler

There is an assumption that the other RGB PPUs are not very different from the 2C04-0003, so this section will be updated as photos of other RGB PPU revisions become available.

|Number|2C02G Terminal|RGB PPU Terminal|
|---|---|---|
|14|EXT0|RED|
|15|EXT1|GREEN|
|16|EXT2|BLUE|
|17|EXT3|AGND|
|21|VOUT|/SYNC|

The following will simply be restored schematics. The original RGB PPU images can be found here: https://siliconpr0n.org/map/nintendo/rp2c04-0003/

![2C04-0003_RGB_PPU](/BreakingNESWiki/imgstore/ppu/rgb/2C04-0003_RGB_PPU.png)

## FSM

It is based on the 2C02 FSM.

![HV_FSM](/BreakingNESWiki/imgstore/ppu/rgb/HV_FSM.png)

The `BURST` signal circuit is present, but the signal itself is not used.

![FSM_BURST](/BreakingNESWiki/imgstore/ppu/rgb/FSM_BURST.jpg)

## EVEN/ODD

The Even/Odd circuit is present but disconnected, the NOR input where the `EvenOddOut` signal came is grounded.

![evenodd_rgb](/BreakingNESWiki/imgstore/ppu/rgb/evenodd_rgb.png)

![evdd](/BreakingNESWiki/imgstore/ppu/rgb/evdd.png)

## COLOR_CONTROL

![COLOR_CONTROL](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_CONTROL.png)

## COLOR_BUFFER_BIT

![CB_BIT](/BreakingNESWiki/imgstore/ppu/rgb/CB_BIT.png)

## CRAM

![COLOR_RAM](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_RAM.png)

![COLOR_IO_RGB](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_IO_RGB.png)

## REG_SELECT

![REG_SELECT](/BreakingNESWiki/imgstore/ppu/rgb/REG_SELECT.png)

## CONTROL_REGS

The `/SLAVE` signal is not used.

![Control_REGs](/BreakingNESWiki/imgstore/ppu/rgb/Control_REGs.png)

## MUX

The input signals `EXT_IN` are `0` and the output signals `/EXT_OUT` are not used.

![MUX](/BreakingNESWiki/imgstore/ppu/rgb/MUX.png)

## OAM_BUF_CONTROL

Reduced write delay. The number of latches is 2 less compared to the composite PPU revisions.

![OAM_BUF_CONTROL](/BreakingNESWiki/imgstore/ppu/rgb/OAM_BUF_CONTROL.png)

## OAM_BIT

![2C04_OAM_buf](/BreakingNESWiki/imgstore/ppu/rgb/2C04_OAM_buf.jpg)

## Video Out

![RGB_VIDEO_OUT](/BreakingNESWiki/imgstore/ppu/rgb/RGB_VIDEO_OUT.png)

## SEL_12x3

![SEL12x3](/BreakingNESWiki/imgstore/ppu/rgb/SEL12x3.png)

FF:

![SEL12x3_FF](/BreakingNESWiki/imgstore/ppu/rgb/SEL12x3_FF.png)

## COLOR_DECODER_RED

![SEL16x12_RED](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_RED.png)

|Output|Bitmask|
|---|---|
|0|1010100001110110|
|1|1111000101010100|
|2|0000110101000000|
|3|0101111001100110|
|4|1000000001111011|
|5|0110110110110100|
|6|0001100101010011|
|7|1111101000110111|
|8|1010000001111000|
|9|1111110100111100|
|10|0110100101101001|
|11|1111100100010110|

(lsb first, 1 means there is a transistor, 0 means there is no transistor)

## COLOR_DECODER_GREEN

![SEL16x12_GREEN](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_GREEN.png)

|Output|Bitmask|
|---|---|
|0|1010110001010110|
|1|0101010111100101|
|2|0000100101110000|
|3|1110101111001101|
|4|0001110011100001|
|5|0101111010010100|
|6|0100111111011000|
|7|1000001010111111|
|8|1010010001011110|
|9|0101110101011100|
|10|1010101111010110|
|11|1010010010111011|

(lsb first, 1 means there is a transistor, 0 means there is no transistor)

## COLOR_DECODER_BLUE

![SEL16x12_BLUE](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_BLUE.png)

|Output|Bitmask|
|---|---|
|0|1110100100100110|
|1|0111011110100100|
|2|1011101101111001|
|3|0110011011100010|
|4|0000100110000111|
|5|0111101110110100|
|6|1010101001100100|
|7|0110011010101110|
|8|1010100101000110|
|9|1111101111111100|
|10|1011101001100100|
|11|0010110010101110|

(lsb first, 1 means there is a transistor, 0 means there is no transistor)

## RGB_DAC

![RGB_DACs](/BreakingNESWiki/imgstore/ppu/rgb/RGB_DACs.png)

## /SYNC

![RGB_SYNC](/BreakingNESWiki/imgstore/ppu/rgb/RGB_SYNC.png)

![nSYNC_PAD](/BreakingNESWiki/imgstore/ppu/rgb/nSYNC_PAD.png)

# UMC 6538

Differences between UMC UA6538 PPU clone and reference PAL PPU (RP2C07).

## H Decoder

![hpla](/BreakingNESWiki/imgstore/ppu/6538/hpla.jpg)

Not different from 2C07.

## V Decoder

![vpla](/BreakingNESWiki/imgstore/ppu/6538/vpla.jpg)

It differs only in one output VPLA_4, which is triggered 50 lines later. The output is responsible for generating the `/VSET` signal, which is used by the PPU interrupt generation circuitry.

## EVEN/ODD

In fact, the circuit is so called because in the NTSC PPU it is responsible for the Dot Crawl. For PAL-like PPUs, this circuit does something else entirely, but the name remains the same.

The OAM1 address counter increment locking circuit in 6538 is disabled, although it is physically present on the chip. The circuit blocks attempts to write to OAM1 during VBLANK (from line 265 to 311).

![odd-even-zomg-6538](/BreakingNESWiki/imgstore/ppu/6538/odd-even-zomg-6538.jpg)

## Sprite Eval

The OAM8 signal (address selection OAM1 or OAM2) has an additional buffer for signal amplification, as its trace has a decent length.

![oam8-buff](/BreakingNESWiki/imgstore/ppu/6538/oam8-buff.jpg)

## DAC

The DAC is significantly redesigned, so the 6538 signal levels are different (a little brighter).

![dac](/BreakingNESWiki/imgstore/ppu/6538/dac.jpg)

(UMC 6538 to the left)

## What is NOT Different

The following circuit elements correspond to the reference PAL PPU 2C07:

- VBL signal output (via latch)
- BLNK in OAM Address
- W3 Enabler
- BLACK signal (additional logic is applied)
- Signal /PICTURE (there are additional latches).
- Chroma Decoder same

# Visual 2C02 Signal Mapping

Visual 2C02: http://www.qmtpro.com/~nes/chipimages/visual2c02/

|Breaks signal name|Visual 2C02 signal name|
|---|---|
|Terminals||
|R/W|node: 1224 io_rw|
|D 0-7|io_db0-7|
|RS 0-2|io_ab0-2|
|/DBE|node: 5 io_ce|
|EXT 0-3|exp0-3|
|CLK|node: 772 clk0|
|/INT|node: 1031 int|
|ALE|node: 1611 ale|
|AD 0-7|ab0-7|
|A 8-13|ab8-13|
|/RD|node: 2428 rd|
|/WR|node: 2087 wr|
|/RES|node: 1934 res|
|Internal Buses||
|DB 0-7|_io_db0-7|
|PD 0-7|_db0-7|
|OB 0-7|spr_d0-7|
|/PA 0-13|/_ab0-13|
|Clocks||
|/CLK|node: 245 /clk0_int|
|CLK|node: 218 clk0_int|
|/PCLK|node: 58 pclk1|
|PCLK|node: 106 pclk0|
|Registers||
|RES|node: 170 _res|
|RC|node: 128 _res2|
|R/W|node: 79 _io_rw|
|RS 0-2|_io_ab0-2|
|/DBE|node: 77 _io_ce|
|/RD|node: 31 _io_rw_buf|
|/WR|node: 13 _io_dbe|
|/W6/1|node: 255 /w2006a|
|/W6/2|node: 244 /w2006b|
|/W5/1|node: 297 /w2005a|
|/W5/2|node: 291 /w2005b|
|/R7|node: 387 /r2007|
|/W7|node: 414 /w2007|
|/W4|node: 341 /w2004|
|/W3|node: 463 /w2003|
|/R2|node: 205 /r2002|
|/W1|node: 481 /w2001|
|/W0|node: 487 /w2000|
|/R4|node: 83 /r2004|
|I1/32|node: 1277 addr_inc_out|
|OBSEL|node: 1182 /spr_pat_out|
|BGSEL|node: 1177 /bkg_pat_out|
|O8/16|node: 1058 spr_size_out|
|/SLAVE|node: 23 slave_mode|
|VBL|node: 1125 enable_nmi|
|B/W|node: 1111 pal_mono|
|/BGCLIP|node: 1161 bkg_clip_out|
|/OBCLIP|node: 1153 spr_clip_out|
|BGE|node: 1280 bkg_enable_out|
|BLACK|node: 1133 rendering_disabled|
|OBE|node: 1267 spr_enable_out|
|/TR|node: 1184 /emph0_out|
|/TG|node: 1168 /emph1_out|
|/TB|node: 1128 /emph2_out|
|H/V FSM||
|H 0-8|hpos0-8|
|V 0-8|vpos0-8|
|S/EV|node: 1070 ++hpos_eq_65_and_rendering|
|CLIP_O|node: 1114 ++in_clip_area_and_clipping_spr|
|CLIP_B|node: 1117 ++in_clip_area_and_clipping_bg|
|0/HPOS|node: 1096 ++hpos_eq_339_and_rendering|
|/EVAL|node: 708 ++/hpos_eq_63_255_or_339_and_rendering|
|E/EV|node: 1009 ++hpos_eq_255_and_rendering|
|I/OAM2|node: 357 ++hpos_lt_64_and_rendering|
|PAR/O|node: 328 ++hpos_eq_256_to_319_and_rendering|
|/VIS|node: 283 ++/in_visible_frame_and_rendering|
|#F/NT|node: 1051 ++/hpos_mod_8_eq_0_or_1_and_rendering|
|F/TB|node: 1091 ++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_6_or_7_and_rendering|
|F/TA|node: 1093 ++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_4_or_5_and_rendering|
|F/AT|node: 1162 +hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3_and_rendering|
|/FO|node: 1090 ++hpos_eq_0-255_or_320-335_and_rendering|
|BPORCH|node: 1002 +hpos_eq_270_to_327|
|SC/CNT|node: 1003 +hpos_eq_279_to_303_and_rendering_enabled|
|/HB|node: 1007 +hpos_eq_279_to_303|
|BURST|node: 547 in_range_3|
|SYNC|node: 915 in_range_2|
|/PICTURE|node: 949 ++/in_draw_range|
|RESCL|node: 604 vbl_clear_flags|
|VSYNC|node: 1079 +/in_range_1|
|/VSET|node: 1015 +/vpos_eq_241_2|
|VB|node: 1100 in_vblank|
|BLNK|node: 1030 not_rendering|
|BLNK (Outside)|node: 203 not_rendering_2|
|INT|node: 988 _int|
|H0'|node: 614 +hpos0|
|H0''|node: 282 ++hpos0|
|H0'' (2)|node: 589 ++hpos0_2|
|/H1'|node: 1006 +/hpos1|
|H1''|node: 1179 ++hpos1|
|/H2'|node: 638 +/hpos2|
|H2''|node: 1173 ++hpos2|
|H3''|node: 1167 ++hpos3|
|H4''|node: 1159 ++hpos4|
|H5''|node: 1109 ++hpos5|
|EvenOddOut|node: 802 skip_dot|
|HC|node: 171 +move_to_next_line|
|VC|node: 172 +clear_vpos_next|
|V_IN|node: 116 hpos_eq_340|
|MPX||
|/ZCOL0|node: 1680 spr_out_/pat0|
|/ZCOL1|node: 1674 spr_out_/pat1|
|ZCOL2|node: 1520 spr_out_attr0|
|ZCOL3|node: 1525 spr_out_attr1|
|/ZPRIO|node: 1528 spr_out_prio|
|/SPR0HIT|node: 1349 /spr_slot_0_opaque|
|EXT_In 0-3|exp_in0-3|
|/EXT_Out 0-3|/exp_out0-3|
|CRAM||
|#CB/DB|node: 1207 /read_2007_output_palette|
|/BW|node: 1350 (++in_draw_range_or_read_2007_output_palette)_and_/pal_mono|
|#DB/CB|node: 1276 /(ab_in_palette_range_and_not_rendering_and_+write_2007_ended)_2|
|PAL 0-4|pal_ptr0-4|
|/CC 0-3|node: 811 +/pal_d0_out; node: 872 +/pal_d1_out; node: 810 +/pal_d2_out; node: 812 +/pal_d3_out|
|/LL 0-1|node: 1216 +++/pal_d4_out; node: 1157 +++/pal_d5_out|
|OAM Eval||
|OMSTEP|node: 288 spr_addr_load_next_value|
|OMOUT|node: 179 /spr_load_next_value_or_write_2003_reg|
|ORES|node: 743 clear_spr_ptr|
|OSTEP|node: 735 inc_spr_ptr|
|OVZ|node: 1052 sprite_in_range|
|OMFG|node: 118 /spr_eval_copy_sprite|
|OMV|node: 455 spr_addr_7_carry_out|
|TMV'|node: 608 +spr_ptr4_carry_out|
|COPY_STEP|node: 1077 ++hpos0_2_and_pclk_1|
|DO_COPY|node: 1047 copy_sprite_to_sec_oam|
|COPY_OVF|node: 5853 do_copy_sprite_to_sec_oam|
|OAM||
|/SPR0_EV|node: 1105 /sprite_0_on_cur_scanline|
|OFETCH|node: 157 delayed_write_2004_value|
|SPR_OV|node: 272 end_of_oam_or_sec_oam_overflow|
|OAMCTR2|node: 300 spr_ptr_overflow|
|/OAM 0-7|node: 57 /spr_addr0_out; etc|
|OAM8|node: 37 spr_ptr5|
|PD/FIFO|node: 1098 +sprite_in_range_reg|
|OV 0-7|+vpos_minus_spr_d0-7|
|/WE|node: 334 oam_write_disable|
|OAM FIFO||
|/SH2|node: 1322 /spr_loadFlag|
|/SH3|node: 1311 /spr_loadX|
|/SH5|node: 1337 /spr_loadL|
|/SH7|node: 1329 /spr_loadH|
|#0/H|node: 1681 +++++/hpos_eq_339_and_rendering|
|DataReader||
|CLPO|node: 1283 ++++/do_sprite_render_ops|
|/CLPB|node: 1281 +++do_bg_render_ops|
|BGC 0-3|pixel_color0-3|
|FH 0-2|finex0-2|
|FV 0-2|node: 2341 vramaddr_t12; node: 2340 vramaddr_t13; node: 2339 vramaddr_t14|
|NTV|node: 2342 vramaddr_t11|
|NTH|node: 2343 vramaddr_t10|
|TV 0-4|vramaddr_t5-9|
|TH 0-4|vramaddr_t0-4|
|THO 0-4|node: 1558 vramaddr_v0_out; etc|
|/THO 0-4|vramaddr_/v0-4|
|TVO 0-4|node: 2268 vramaddr_v5_out; etc|
|/TVO 0-4|vramaddr_/v5-9|
|FVO 0-2|node: 2272 vramaddr_v13_out (FVO1)|
|/FVO 0-2|node: 1872 vramaddr_/v12; etc|
|/PAD 0-12|node: 9046 +++/vpos_minus_spr_d0_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v12 (:crazy:); etc|
|VRAM Controller||
|RD|node: 1960 _rd|
|WR|node: 2048 _wr|
|/ALE|node: 1593 /_ale|
|TSTEP|node: 2266 reading_or_writing_2007|
|DB/PAR|node: 1275 write_2007_ended_2|
|PD/RB|node: 2325 read_2007_ended_2|
|TH/MUX|node: 1266 ab_in_palette_range_and_not_rendering_2|
|XRB|node: 2327 read_2007_output_vrambuf_2|
|VideoOut||
|L0|node: 751 vid_sync_l|
|L1|node: 4941 vid_burst_l|
|L2|node: 5538 vid_luma0_l|
|L3|node: 787 vid_sync_h; node: 5835 vid_luma1_l|
|L4|node: 4942 vid_burst_h|
|L5|node: 5912 vid_luma2_l|
|L6|node: 5556 vid_luma0_h|
|L7|node: 5842 vid_luma1_h|
|L8|node: 5805 vid_luma3_l|
|L9|node: 5925 vid_luma2_h; node: 5784 vid_luma3_h|
|TINT|node: 954 vid_emph|
|PBLACK|node: 542 +++pal_d3-1_eq_7|
|/PR|node: 193 chroma_ring5|
|/PB|node: 195 chroma_ring3|
|/PG|node: 197 chroma_ring1|
|/PZ|node: 381 chroma_waveform_out|
|/POUT|node: 918 /(+in_draw_range_and_++/pal_d3-1_eq_7)|

# Waves

This section contains signal timings for different PPU units. Circuit engineers like to look thoughtfully at these.

The sources of all the tests that were used to make the diagrams are in the folder `/HDL/Framework/Icarus`.

## PCLK

## H/V Counters

## H/V Decoders

## FSM Delayed H Outputs

## FSM State Signals

The states within the scanline:

![fsm_scan](/BreakingNESWiki/imgstore/ppu/waves/fsm_scan.png)

States inside VBlank:

![fsm_vblank](/BreakingNESWiki/imgstore/ppu/waves/fsm_vblank.png)

Note that the figure with the scalines is scaled up (as seen by the change in the pixel counter H), compared to the scale in the VBlank figure (as seen by the change in the line counter V).

## OAM Evaluate

## OAM Comparator

## SpriteH Signals

## PAR Control

## OAM FIFO Lane

## VRAM Controller

## Video Output

Demonstration of the phase shifter output, with phases arranged according to the colors of the PPU palette (1 "pixel" is highlighted by a frame):

![phase_shifter](/BreakingNESWiki/imgstore/ppu/waves/phase_shifter.png)

![phase_shifter2](/BreakingNESWiki/imgstore/ppu/waves/phase_shifter2.png)

Demonstration of the selection of 1 of the 12 color phases (signal `/PZ`):

![phase_color](/BreakingNESWiki/imgstore/ppu/waves/phase_color.png)

# Synchronous analysis

TBD.

# PPU on YouTube

Every man after 30 must do a YouTube video about the PPU.

Here we have a small collection of such videos.

<a href='http://www.youtube.com/watch?feature=player_embedded&v=ZWQ0591PAxM' target='_blank'><img src='http://img.youtube.com/vi/ZWQ0591PAxM/0.jpg' width='425' height=344 /></a>

<a href='http://www.youtube.com/watch?feature=player_embedded&v=7Co_8dC2zb8' target='_blank'><img src='http://img.youtube.com/vi/7Co_8dC2zb8/0.jpg' width='425' height=344 /></a>

<a href='http://www.youtube.com/watch?feature=player_embedded&v=wt73KPS_23w' target='_blank'><img src='http://img.youtube.com/vi/wt73KPS_23w/0.jpg' width='425' height=344 /></a>

<a href='http://www.youtube.com/watch?feature=player_embedded&v=E4RbOfKB2Js' target='_blank'><img src='http://img.youtube.com/vi/E4RbOfKB2Js/0.jpg' width='425' height=344 /></a>

<a href='http://www.youtube.com/watch?feature=player_embedded&v=b_EikcF84wk' target='_blank'><img src='http://img.youtube.com/vi/b_EikcF84wk/0.jpg' width='425' height=344 /></a>

<a href='http://www.youtube.com/watch?feature=player_embedded&v=cksywUTZxlY' target='_blank'><img src='http://img.youtube.com/vi/cksywUTZxlY/0.jpg' width='425' height=344 /></a>
