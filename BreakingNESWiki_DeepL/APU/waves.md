# Waves

This section contains signal timings for different APU units. Circuit engineers like to look thoughtfully at these.

The timeline is respected more or less accurately only for SoftCLK LFO signals, in other cases the timescale is chosen arbitrarily (it makes no sense to make it accurate).

## CLK Divider

![div](/BreakingNESWiki/imgstore/apu/waves/div.png)

The external `CLK` pad, the `PHI0` signal for the core, and the signal of the external `M2` pad are shown.

## ACLK Generator

Under reset conditions:

![aclk_with_reset](/BreakingNESWiki/imgstore/apu/waves/aclk_with_reset.png)

Without reset:

![aclk](/BreakingNESWiki/imgstore/apu/waves/aclk.png)

## SoftCLK counter (LFSR)

![softclk_lfsr](/BreakingNESWiki/imgstore/apu/waves/softclk_lfsr.png)

## SoftCLK PLA, low frequency oscillation signals (LFO) and interrupts

Mode = 0:

![softclk_mode0](/BreakingNESWiki/imgstore/apu/waves/softclk_mode0.png)

Mode = 1:

![softclk_mode1](/BreakingNESWiki/imgstore/apu/waves/softclk_mode1.png)

## Register Operations Decoder

Read Registers:

![regops_read](/BreakingNESWiki/imgstore/apu/waves/regops_read.png)

Write Registers:

![regops_write](/BreakingNESWiki/imgstore/apu/waves/regops_write.png)

## Length Counters Decoder

![length_decoder](/BreakingNESWiki/imgstore/apu/waves/length_decoder.png)
