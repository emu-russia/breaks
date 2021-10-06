# APU Overview

**APU** is the unofficial name for the specialized NES CPU.

The official name is MPU (Microprocessor Unit), but we will stick to the unofficial term. Sometimes APU is also found under the abbreviation "pAPU" (Pseudo-APU).

The chip was developed by [Ricoh](../Ricoh.md), chip names are RP2A03 for NTSC and RP2A07 for PAL.

The APU includes:
- MOS 6502 processor core, with disabled decimal correction (BCD) circuit
- DMA to send sprites (hardwired to external PPU registers)
- Tone generators: 2 square, 1 triange, 1 noise generator and 1 delta-PCM.
- DACs to convert digital outputs of synthesized sound to analog levels
- DMA for sampling DPCM samples
- Small DMA controller
- Low-frequency oscillator (commonly known as `Frame counter`)
- Input clock frequency divider
- I/O ports (which are used to receive data from controllers in NES)
- Debug registers (not available on Retail consoles)

The DAC makes the APU a semi-analog circuit, but the digital outputs of the tone generators can be used for simulation.

Also to be taken into account is the fact that the 6502 core which is part of the APU is controlled by a DMA controller and therefore is a "common" device sharing the bus with other devices which use DMA.

<img src="/BreakingNESWiki/imgstore/apu_blocks.jpg" width="900px">

[nesdev.com / 2A03 Technical Reference](http://nesdev.com/2A03%20technical%20reference.txt)
