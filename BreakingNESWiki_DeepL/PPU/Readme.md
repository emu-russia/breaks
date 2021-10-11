# PPU Overview

PPU (Picture Processing Unit) - a specialized IC for generating a video signal.

Sample picture that the PPU can produce:

<img src="/BreakingNESWiki/imgstore/battletoads.png" width="400px">

There are the following versions of the PPU chips:
- 2C02: used in the Famicom and the American version of the NES. It generates an NTSC signal.
- 2C03, 2C04, 2C05: RGB-versions for arcade machines based on NES (PlayChoiсe-10, Vs. System)
- 2C07: PAL version of the PPU for the European NES.

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
- Sprite Logic. Based on the H-counter, selects the 8 current sprites which are placed in additional OAM memory during the comparison process.
- Sprite FIFO (OAM FIFO). Contains a circuit that activates the output of the 8 selected sprites at the right time, as well as a circuit to control their priority.
- Address bus control circuitry. Controls the VRAM addressing.
- Data reader circuit (data fetcher). Circuit for fetching source data from VRAM: tiles and attributes.
