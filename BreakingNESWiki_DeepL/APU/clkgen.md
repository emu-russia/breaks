# Timing Generator

![apu_locator_clkgen](/BreakingNESWiki/imgstore/apu/apu_locator_clkgen.jpg)

The timing generator contains the following components:
- ACLK generator
- Software timer (also known as `Frame Counter`)
- Also implements Daisy-chain interrupt forwarding from DPCM and mixing in its own timer interrupt if needed

## ACLK Generator

The ACLK generator is used to generate an internal ACLK clock signal (APU CLK), based on the 6502 CPU clock frequency.

![aclk_gen_tran](/BreakingNESWiki/imgstore/apu/aclk_gen_tran.jpg)

![ACLK_Gen](/BreakingNESWiki/imgstore/apu/ACLK_Gen.jpg)

The `ACLK` and `/ACLK` signals are not complementary and have an overlap:

![aclk](/BreakingNESWiki/imgstore/apu/waves/aclk.png)

## Software Timer

From the official documentation we know that this component is called `Soft CLK`.

The purpose of this device is to provide the programmer with a tool to add periodic actions to the game program, repeated about every frame.

Soft CLK features:
- Operating modes (normal and extended)
- Generating interrupts
- Timing the remaining APU tone generators with low-frequency signals (`/LFO1`, `/LFO2`)

![SoftCLK](/BreakingNESWiki/imgstore/apu/SoftCLK.jpg)

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
- INT: Joint SoftCLK or DPCM interrupt signal
- RES: internal reset signal (derived from /RES pin)

Soft CLK Counter Control:

![softclk_counter_control_tran](/BreakingNESWiki/imgstore/apu/softclk_counter_control_tran.jpg)

Logic:

![SoftCLK_Control](/BreakingNESWiki/imgstore/apu/SoftCLK_Control.jpg)

### Soft CLK Counter

It is a Johnson counter with feedback.

![softclk_counter_tran](/BreakingNESWiki/imgstore/apu/softclk_counter_tran.jpg)

![SoftCLK_SR](/BreakingNESWiki/imgstore/apu/SoftCLK_SR.jpg)

![SoftCLK_SRBit](/BreakingNESWiki/imgstore/apu/SoftCLK_SRBit.jpg)

A special feature is the inverse input for the shift register. The outputs of the shift register (in complementary form) are fed to the decoder input (PLA).

### PLA

```
111110
000001
011100
100011
000110
111001
000100
111011
001100
110011
100000
011111
101000
010111
001010
110101
000010
111101
010100
101011
011000
100111
001100
110011
110010
001101
011010
100101
000010
111101
```

The placement is topological. 1 means there is a transistor, 0 means there is no transistor.

![SoftCLK_PLA](/BreakingNESWiki/imgstore/apu/SoftCLK_PLA.jpg)

## Other /ACLKs

There are "other" /ACLKs in different parts of the APU.

At first a "other" /ACLK was found in the DPCM/DMA circuit, but then it turned out that they are also found in other parts of the APU. Therefore, these signals are called in order of 2, 3, 4, etc.

In the diagrams :warning: sign marks the places where other `/ACLK` is used.

## /ACLK2

In the very center of the DPCM circuitry is a circuit to produce the "other" /ACLK that is used in [DPCM](dpcm.md) as well as in [sprite DMA](dma.md).
This signal can be found in our circuits as `/ACLK2`.

![nACLK2](/BreakingNESWiki/imgstore/apu/nACLK2.jpg)

### /ACLK3

Used for [square wave sound generators](square.md), and more specifically for the $4002/$4003 registers.

![nACLK3](/BreakingNESWiki/imgstore/apu/nACLK3.jpg)

For the first square channel (Square 0 = A), the signal is called `/ACLK3A`.

For the second square channel (Square 1 = B) the signal is called `/ACLK3B`.

But in the general schematic for the two channels, the signal is simply marked as `/ACLK3`.

### /ACLK4

Used in the [noise generator](noise.md) and [length counter](length.md) control circuitry.

![nACLK4](/BreakingNESWiki/imgstore/apu/nACLK4.jpg)

### /ACLK5

Used in I/O latches that generate OUTx signals for the corresponding output terminals.

![nACLK5](/BreakingNESWiki/imgstore/apu/nACLK5.jpg)
