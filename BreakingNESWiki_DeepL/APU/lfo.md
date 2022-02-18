# LFO

![apu_locator_lfo](/BreakingNESWiki/imgstore/apu/apu_locator_lfo.jpg)

The Low-frequency oscillator (LFO) or Frame Counter is a dedicated timer inside the APU which, by definition, operates at a relatively low frequency, close to the PPU frame rate.

The purpose of this device is to provide the programmer with a tool to add periodic actions to the game program, repeated approximately every frame.

LFO capabilities:
- PAL/NTSC operation modes
- Generating interrupts
- Timing other APU tone generators with low-frequency signals (/LFO1, /LFO2)
- Generation of internal clock signal ACLK (APU CLK), based on CPU clock frequency

## Programming Model

The LFO is controlled by register $4017 (write-only):
- $4017\[6\]: masks the LFO interrupt (1-LFO interrupt disable, 0-enable)
- $4017\[7\]: Writing to this bit selects NTSC/PAL mode (0/1).

Bit $4015\[6] contains the interrupt status.

## ACLK Generator

![lfo_aclk_gen_tran](/BreakingNESWiki/imgstore/apu/lfo_aclk_gen_tran.jpg)

![ACLK_Gen](/BreakingNESWiki/imgstore/apu/ACLK_Gen.jpg)

## LFO Control

![lfo_control_tran](/BreakingNESWiki/imgstore/apu/lfo_control_tran.jpg)

- /R4015 and W4017: come from the register selector when reading $4015 and writing to $4017 registers respectively
- D6 and D7: bits 6 and 7 of the internal data bus
- /LFO1 and /LFO2: low frequency output signals
- /DMCINT: DPCM interrupt signal
- INT: Joint LFO or DPCM interrupt signal
- RES: internal reset signal (derived from /RES pin)

## LFO Counter

![lfo_counter_tran](/BreakingNESWiki/imgstore/apu/lfo_counter_tran.jpg)

## LFO Counter Control

![lfo_counter_control_tran](/BreakingNESWiki/imgstore/apu/lfo_counter_control_tran.jpg)
