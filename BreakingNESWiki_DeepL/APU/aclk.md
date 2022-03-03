# Timing Generator

![apu_locator_clkgen](/BreakingNESWiki/imgstore/apu/apu_locator_clkgen.jpg)

The timing generator contains the following components:
- ACLK generator
- Software timer (also known as `Frame Counter`)

## ACLK Generator

The ACLK generator is used to generate an internal ACLK clock signal (APU CLK), based on the 6502 CPU clock frequency.

![aclk_gen_tran](/BreakingNESWiki/imgstore/apu/aclk_gen_tran.jpg)

![ACLK_Gen](/BreakingNESWiki/imgstore/apu/ACLK_Gen.jpg)

## Software Timer

From the official documentation we know that this component is called `Soft CLK`.

The purpose of this device is to provide the programmer with a tool to add periodic actions to the game program, repeated about every frame.

Soft CLK features:
- Operating modes (normal and extended)
- Generating interrupts
- Timing the remaining APU tone generators with low-frequency signals (`/LFO1`, `/LFO2`)

### Programming Model

Soft CLK is controlled by register $4017 (write-only):
- $4017\[6\]: Mask interrupt (1: interrupt disable, 0: enable)
- $4017\[7\]: Writing to this bit selects mode (0: normal mode, 1: extended mode)

Bit $4015\[6\] contains the interrupt status.

### Soft CLK Control

![softclk_control_tran](/BreakingNESWiki/imgstore/apu/softclk_control_tran.jpg)

- /R4015 and W4017: come from the register selector when reading $4015 and writing to $4017 registers respectively
- D6 and D7: bits 6 and 7 of the internal data bus
- /LFO1 and /LFO2: low frequency output signals
- DMCINT: DPCM interrupt signal
- INT: Joint LFO or DPCM interrupt signal
- RES: internal reset signal (derived from /RES pin)

### Soft CLK Counter

![softclk_counter_tran](/BreakingNESWiki/imgstore/apu/softclk_counter_tran.jpg)

### Soft CLK Counter Control

![softclk_counter_control_tran](/BreakingNESWiki/imgstore/apu/softclk_counter_control_tran.jpg)
