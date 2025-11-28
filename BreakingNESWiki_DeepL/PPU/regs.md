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

As you know, 2 consecutive writes to registers $2005 or $2006 actually write a value to the [dual registers $2005/$2006](scroll_regs.md) (FV/FH/TV/TH).

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
|CLPO|Regs|FIFO|1: Clip sprites. Final signal for Obj FIFO circuit|
