# APU Overview

:warning: The names and polarities of internal APU signals are being actively discussed and corrected. There may also be minor issues in the schematics. But a critical mass of information is already contained here and that's a good thing. This mention will disappear after all the points are settled and all APU circuits are verified by simulation.

**APU** is the unofficial name for the specialized NES CPU.

The official name is just CPU, but we will stick to the unofficial term.

The chip was developed by [Ricoh](../Ricoh.md), chip names are RP2A03 for NTSC and RP2A07 for PAL.

![APU](/BreakingNESWiki/imgstore/apu/APU.jpg)

The APU includes:
- MOS 6502 processor core, with disabled decimal correction (BCD) circuit
- Input clock frequency divider
- Software Timer (commonly known as `Frame counter`)
- Sound generators: 2 square channels, 1 triangle, 1 noise generator, Delta PCM
- DMA for sampling DPCM samples
- DACs to convert digital outputs of synthesized sound to analog levels
- DMA to send sprites (hardwired to external PPU register $2004) and dedicated DMA controller
- I/O ports (which are usually used to receive data from controllers in NES)
- Debug registers (not available on Retail consoles)

The DAC makes the APU a semi-analog circuit.

Also to be taken into account is the fact that the 6502 core which is part of the APU is controlled by a DMA controller and therefore is a "common" device sharing the bus with other devices which use DMA.

![apu_blocks](/BreakingNESWiki/imgstore/apu/apu_blocks.jpg)

## Note on Transistor Circuits

The transistor circuits for each component are chopped up into component parts so that they don't take up too much space.

To keep you from getting lost, each section includes a special "locator" at the beginning that marks the approximate location of the component being studied.

An example of a locator:

![apu_locator_dma](/BreakingNESWiki/imgstore/apu/apu_locator_dma.jpg)

## Note on Logic Circuits

The logic circuits are mostly made in the Logisim program. The following element is used to denote DLatch:

|DLatch (transistor circuit)|DLatch (logic equivalent)|
|---|---|
|![dlatch_tran](/BreakingNESWiki/imgstore/dlatch_tran.jpg)|![dlatch_logic](/BreakingNESWiki/imgstore/dlatch_logic.jpg)|

For convenience, the logical variant of DLatch has two outputs (`out` and `/out`), since the current value of DLatch (out) is often used as an input of a NOR operation.
