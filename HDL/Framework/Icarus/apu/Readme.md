# APU Tests

Various tests for APU components.

## apu

Check that the APU is moving.

The test runs the APU "idle" a number of cycles and ends. Just to check that the sources do not contain errors.

## aux_test

Check the operation of the DAC.

Runs all digital AUX A/B values and saves a dump of analog levels in the normalized little-endian float format \[-1.0; +1.0\] (to be checked in Audacity).

![aux_test](/BreakingNESWiki/imgstore/apu/waves/aux_test.png)

## clkgen

A unit test for checking APU Clock Trees.

The idea is simple. We start a negedge counter for the CLK and check the transit of child clocks.

![aclk](/BreakingNESWiki/imgstore/apu/waves/aclk.png)

## clkgen_with_reset

A unit test for checking APU Clock Trees.

Just do a few iterations with reset, then no reset.

![aclk_with_reset](/BreakingNESWiki/imgstore/apu/waves/aclk_with_reset.png)

## DivSRBit

Test CLK Divider shift register.

![div](/BreakingNESWiki/imgstore/apu/waves/div.png)

## dpcm_decoder

Run all DPCM decoder values.

![dpcm_decoder](/BreakingNESWiki/imgstore/apu/waves/dpcm_decoder.png)

## dpcm_output

Test for playing a DPCM sample.

From the APU only the ACLK generator and the DPCM channel itself are used.
The DPCM samples are in the `dpcm_sample.mem` file and are loaded into a dummy memory device which is addressed by `DMC_Addr`.

![dpcm_output](/BreakingNESWiki/imgstore/apu/waves/dpcm_output.png)

## env_unit

Testing the Envelope Unit.

![env_unit](/BreakingNESWiki/imgstore/apu/waves/env_unit.png)

:warning: The simulation of LFO generation is artificially tweaked to trigger more frequently.

## length_counter

Synthetic Length Counter testing.

Doing a full run at the ACLK frequency for LFO2 would be too long, so we simulate more frequent triggering of LFO2.

The purpose of the test is to load the value through the decoder and see what happens before the NoCount signal is triggered.

![length_counter](/BreakingNESWiki/imgstore/apu/waves/length_counter.png)

## length_decoder

Run all Length decoder values.

![length_decoder](/BreakingNESWiki/imgstore/apu/waves/length_decoder.png)

## noise_decoder

Run all Noise decoder values.

![noise_decoder](/BreakingNESWiki/imgstore/apu/waves/noise_decoder.png)

## oam_dma

Test bench setup:

![oam_dma_tb](/BreakingNESWiki/imgstore/apu/waves/oam_dma_tb.png)

Aligned OAM DMA:

![oam_dma_start1](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start1.png)

Unaligned OAM DMA:

![oam_dma_start2](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start2.png)

![oam_dma_last](/BreakingNESWiki/imgstore/apu/waves/oam_dma_last.png)

## both_dma

Test bench setup:

![both_dma_tb](/BreakingNESWiki/imgstore/apu/waves/both_dma_tb.png)

![both_dma_start_dpcm](/BreakingNESWiki/imgstore/apu/waves/both_dma_start_dpcm.png)

![both_dma_start_oam](/BreakingNESWiki/imgstore/apu/waves/both_dma_start_oam.png)

![both_dma](/BreakingNESWiki/imgstore/apu/waves/both_dma.png)

![both_dma_zoom](/BreakingNESWiki/imgstore/apu/waves/both_dma_zoom.png)

![both_dma_last_oam](/BreakingNESWiki/imgstore/apu/waves/both_dma_last_oam.png)

![both_dma_after_oam_before_next_dpcm](/BreakingNESWiki/imgstore/apu/waves/both_dma_after_oam_before_next_dpcm.png)

![both_side_by_side](/BreakingNESWiki/imgstore/apu/waves/both_side_by_side.png)

## regops

Testing register operations.

Simply go through the addresses in the APU address space and display the VCD of all RegOps signals.

![regops_read](/BreakingNESWiki/imgstore/apu/waves/regops_read.png)

![regops_write](/BreakingNESWiki/imgstore/apu/waves/regops_write.png)

## softclk

A unit test for checking SoftCLK in different modes.

This is not a unit test right now, we are just doing some preliminary SoftCLK fiddling and looking at the signals.

![softclk_mode0](/BreakingNESWiki/imgstore/apu/waves/softclk_mode0.png)

## square_barrel

Check all possible values of the shifter used in square channels.

![square_barrel](/BreakingNESWiki/imgstore/apu/waves/square_barrel.png)

## square_adder

Testing of the adder of a square wave sound generator.

This test runs a test vector exclusively for Adder and its single bit (full adder) circuitry. That is the testing is done abstractly from the APU - just to check that the adder... adds things up :-)

A distinctive feature of the adder is the complementary wiring of the a/b signals and the carry chain and the inverse polarity of the result (#sum) and the output carry (#COUT).

![adder_single](/BreakingNESWiki/imgstore/apu/waves/adder_single.png)

![adder_full](/BreakingNESWiki/imgstore/apu/waves/adder_full.png)

![adder_full_max](/BreakingNESWiki/imgstore/apu/waves/adder_full_max.png)

:warning: The test takes quite a long time (22-bit vector) and generates a .vcd of several hundred MBytes.

## square_sweep

![sweep_tb](/BreakingNESWiki/imgstore/apu/waves/sweep_tb.png)

With this test we are trying to get the Sweep Unit to generate the DO_SWEEP signal as it should be for the Sweep process to work.

That is, we need to organize the artificial generation of /LFO2 signal (not too slow, as in real conditions, to speed up the process)
and check that the DO_SWEEP signal is generated as it should be.

For this test it does not matter what happens to the Freq Reg, shifter, adder and all other parts of the square wave generator.

![sweep_unit](/BreakingNESWiki/imgstore/apu/waves/sweep_unit.png)

:warning: The simulation of LFO generation is artificially tweaked to trigger more frequently.

## square_duty

![duty_tb](/BreakingNESWiki/imgstore/apu/waves/duty_tb.png)

Check the DUTY signal generation, depending on the different Duty register settings and Duty counter values.

The generation of the FLOAD signal (to iterate the Duty counter) is artificially accelerated.

![duty_unit](/BreakingNESWiki/imgstore/apu/waves/duty_unit.png)

## square_output

![square_output](/BreakingNESWiki/imgstore/apu/waves/square_output.png)

## triangle_output

![triangle_output](/BreakingNESWiki/imgstore/apu/waves/triangle_output.png)

## noise_output

![noise_output](/BreakingNESWiki/imgstore/apu/waves/noise_output.png)

## test_counters

Run the counters and see how they work.
