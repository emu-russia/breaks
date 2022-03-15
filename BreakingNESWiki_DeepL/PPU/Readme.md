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
|2C04-0001| |
|2C04-0002| |
|2C04-0003| |
|2C04-0004| |
|2C05| |
|2C07-0|PAL version of the PPU for the European NES.|

Probably exist (but no one has seen them):
- 2C01: Debug version of NTSC PPU (?)
- 2C06: Debug version of PAL PPU (?)

## Architecture

Main components of PPU:

![PPU_preview](/BreakingNESWiki/imgstore/PPU_preview.jpg)

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
