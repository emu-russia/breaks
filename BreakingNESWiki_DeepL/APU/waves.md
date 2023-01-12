# Waves

This section contains signal timings for different APU units. Circuit engineers like to look thoughtfully at these.

The timeline is respected more or less accurately only for SoftCLK LFO signals, in other cases the timescale is chosen arbitrarily (it makes no sense to make it accurate).

The sources of all the tests that were used to make the diagrams are in the folder `/HDL/Framework/Icarus`.

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

## Length Counter

![length_counter](/BreakingNESWiki/imgstore/apu/waves/length_counter.png)

The diagram shows the essence of the operation, with some peculiarities:
- The phase pattern for the ACLK is respected
- The LFO2 frequency that controls the counter counting is not scaled, but synthetically shortened
- The main purpose is to show that after the end of the countdown the circuit generates a `NotCount` signal (which corresponds to the NOSQA/NOSQB/NOTRI/NORND signals for the four real counters)
- Before starting the counter, the value 0b1001 (9) is loaded into the counter, which after processing on the decoder corresponds to the value 0x07.

## Envelope Unit

![env_unit](/BreakingNESWiki/imgstore/apu/waves/env_unit.png)

The simulation of LFO generation is artificially tweaked to trigger more frequently.

## DPCM Decoder

![dpcm_decoder](/BreakingNESWiki/imgstore/apu/waves/dpcm_decoder.png)

## Noise Decoder

![noise_decoder](/BreakingNESWiki/imgstore/apu/waves/noise_decoder.png)

## DPCM Output

![dpcm_output](/BreakingNESWiki/imgstore/apu/waves/dpcm_output.png)

## OAM DMA

Test bench setup:

![oam_dma_tb](/BreakingNESWiki/imgstore/apu/waves/oam_dma_tb.png)

Start of OAM DMA:

![oam_dma_start](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start.png)

Completing an OAM DMA:

![oam_dma_last](/BreakingNESWiki/imgstore/apu/waves/oam_dma_last.png)

## Both DMA

Test bench setup:

![both_dma_tb](/BreakingNESWiki/imgstore/apu/waves/both_dma_tb.png)

Starting DPCM DMA (writing to registers $400x and several iterations of the process):

![both_dma_start_dpcm](/BreakingNESWiki/imgstore/apu/waves/both_dma_start_dpcm.png)

Start of OAM DMA (write to register $4014)

![both_dma_start_oam](/BreakingNESWiki/imgstore/apu/waves/both_dma_start_oam.png)

Moment of intersection of DPCM DMA and OAM DMA:

![both_dma](/BreakingNESWiki/imgstore/apu/waves/both_dma.png)

Moment of intersection of DPCM DMA and OAM DMA (close-up version of a particular moment):

![both_dma_zoom](/BreakingNESWiki/imgstore/apu/waves/both_dma_zoom.png)

Completing an OAM DMA:

![both_dma_last_oam](/BreakingNESWiki/imgstore/apu/waves/both_dma_last_oam.png)

Some lull after the OAM DMA ends and the next DPCM DMA begins:

![both_dma_after_oam_before_next_dpcm](/BreakingNESWiki/imgstore/apu/waves/both_dma_after_oam_before_next_dpcm.png)
