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

:warning: The simulation of LFO generation is artificially tweaked to trigger more frequently.

## Square Barrel Shifter

![square_barrel](/BreakingNESWiki/imgstore/apu/waves/square_barrel.png)

## Square Adder

Full Adder (single bit):

![adder_single](/BreakingNESWiki/imgstore/apu/waves/adder_single.png)

The summation result was somewhere in the middle:

![adder_full](/BreakingNESWiki/imgstore/apu/waves/adder_full.png)

The summation of the maximum values:

![adder_full_max](/BreakingNESWiki/imgstore/apu/waves/adder_full_max.png)

## Square Sweep Unit

![sweep_tb](/BreakingNESWiki/imgstore/apu/waves/sweep_tb.png)

With this test we are trying to get the Sweep Unit to generate the ADDOUT signal as it should be for the Sweep process to work.

That is, we need to organize the artificial generation of /LFO2 signal (not too slow, as in real conditions, to speed up the process)
and check that the ADDOUT signal is generated as it should be.

For this test it does not matter what happens to the Freq Reg, shifter, adder and all other parts of the square wave generator.

![sweep_unit](/BreakingNESWiki/imgstore/apu/waves/sweep_unit.png)

:warning: The simulation of LFO generation is artificially tweaked to trigger more frequently.

## Square Duty Unit

![duty_tb](/BreakingNESWiki/imgstore/apu/waves/duty_tb.png)

Check the DUTY signal generation, depending on the different Duty register settings and Duty counter values.

The generation of the FLOAD signal (to iterate the Duty counter) is artificially accelerated.

![duty_unit](/BreakingNESWiki/imgstore/apu/waves/duty_unit.png)

## DPCM Decoder

![dpcm_decoder](/BreakingNESWiki/imgstore/apu/waves/dpcm_decoder.png)

## Noise Decoder

![noise_decoder](/BreakingNESWiki/imgstore/apu/waves/noise_decoder.png)

## DPCM Output

![dpcm_output](/BreakingNESWiki/imgstore/apu/waves/dpcm_output.png)

## Square Output

![square_output](/BreakingNESWiki/imgstore/apu/waves/square_output.png)

```
W4015 <= 0000000 1  (SQA Length counter enable: 1)
W4000 <= 10 0 0 0110 (D=2, Length Counter #carry in=0, ConstVol=0, Vol=6)
W4001 <= 1 001 0 010 (Sweep=1, Period=1, Negative=0, Magnitude=2^2)
W4002 <= 0110 1001  (Freq Lo=0x69)
W4003 <= 11111 010  (Length=11111, Freq Hi=2)
```

## Triangle Output

![triangle_output](/BreakingNESWiki/imgstore/apu/waves/triangle_output.png)

```
W4015 <= 00000 1 00  (Triangle Length counter enable: 1)
W4008 <= 0 0001111 (Triangle length counter #carry in: 0, Linear counter reload: 0xf)
W400A <= 0110 1001  (Freq Lo=0x69)
W400B <= 11111 010  (Length=11111, Freq Hi=2)
```

## Noise Output

![noise_output](/BreakingNESWiki/imgstore/apu/waves/noise_output.png)

```
W4015 <= 0000 1 000  (Noise Length counter enable: 1)
W400C <= xx 0 0 0110 (Noise Length counter #carry: 0, Constant: 0, Env: 6)
W400E <= 0 xxx 0111 (Loop: 0, Period: 7)
W400F <= 11111 xxx (Length: 11111)
```

## OAM DMA

Test bench setup:

![oam_dma_tb](/BreakingNESWiki/imgstore/apu/waves/oam_dma_tb.png)

Start of OAM DMA (aligned to #ACLK):

![oam_dma_start1](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start1.png)

Start of OAM DMA (unaligned to #ACLK, 1 additional CPU cycle required):

![oam_dma_start2](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start2.png)

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

Regular DPCM DMA versus interleaved OAM DMA:

![both_side_by_side](/BreakingNESWiki/imgstore/apu/waves/both_side_by_side.png)

It can be seen that part of the DPCM DMA cycles are reserved for a possible OAM DMA transfer, since it is impossible to do two reads simultaneously. Therefore there is a "window" at the beginning of the DPCM transfer after which a possible active OAM DMA is suppressed by the RUNDMC signal.
