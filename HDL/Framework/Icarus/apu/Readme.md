# APU Tests

Various tests for APU components.

## apu

Check that the APU is moving.

The test runs the APU "idle" a number of cycles and ends. Just to check that the sources do not contain errors.

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

## regops

Testing register operations.

Simply go through the addresses in the APU address space and display the VCD of all RegOps signals.

![regops_read](/BreakingNESWiki/imgstore/apu/waves/regops_read.png)

![regops_write](/BreakingNESWiki/imgstore/apu/waves/regops_write.png)

## softclk

A unit test for checking SoftCLK in different modes.

This is not a unit test right now, we are just doing some preliminary SoftCLK fiddling and looking at the signals.

![softclk_mode0](/BreakingNESWiki/imgstore/apu/waves/softclk_mode0.png)

## test_counters

Run the counters and see how they work.
