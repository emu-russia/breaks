# Noise Channel

![apu_locator_noise](/BreakingNESWiki/imgstore/apu/apu_locator_noise.jpg)

![NOISE](/BreakingNESWiki/imgstore/apu/NOISE.jpg)

## Frequency Reg

![noise_freq_in_tran](/BreakingNESWiki/imgstore/apu/noise_freq_in_tran.jpg)

![NOISE_FreqReg](/BreakingNESWiki/imgstore/apu/NOISE_FreqReg.jpg)

![RegisterBitRes](/BreakingNESWiki/imgstore/apu/RegisterBitRes.jpg)

A variation of the register with an additional reset (immediately on the latch) is used.

## Decoder

![noise_decoder_tran](/BreakingNESWiki/imgstore/apu/noise_decoder_tran.jpg)

The first stage of the decoder (4-to-16 demultiplexer):

```
00000000 11111111
11111111 00000000
00001111 00001111
11110000 11110000
00110011 00110011
11001100 11001100
01010101 01010101
10101010 10101010
```

The second stage of the decoder:

```
11101111 11111111
10001011 11110111
00111100 11001111
11111110 11110011
01100111 00011111
11110010 00000011
11111111 11000111
11011110 11100001
11011001 01111111
11000001 00010000
11011010 00000111
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

## Frequency LFSR

![noise_freq_lfsr_tran](/BreakingNESWiki/imgstore/apu/noise_freq_lfsr_tran.jpg)

![noise_freq_control_tran](/BreakingNESWiki/imgstore/apu/noise_freq_control_tran.jpg)

![NOISE_FreqLFSR](/BreakingNESWiki/imgstore/apu/NOISE_FreqLFSR.jpg)

![FreqLFSRBit](/BreakingNESWiki/imgstore/apu/FreqLFSRBit.jpg)

## Random LFSR

![noise_random_lfsr_tran](/BreakingNESWiki/imgstore/apu/noise_random_lfsr_tran.jpg)

![noise_feedback_tran](/BreakingNESWiki/imgstore/apu/noise_feedback_tran.jpg)

![NOISE_RandomLFSR](/BreakingNESWiki/imgstore/apu/NOISE_RandomLFSR.jpg)

![RandomLFSRBit](/BreakingNESWiki/imgstore/apu/RandomLFSRBit.jpg)

The shift register design for Random LFSR is different in that the value is stored in a register (static memory), because significant time can pass between shifts of the value and therefore you can not use shift registers on a dynamic memory (DLatch).

## Envelope

![noise_envelope_rate_counter_tran](/BreakingNESWiki/imgstore/apu/noise_envelope_rate_counter_tran.jpg)

![noise_envelope_control_tran](/BreakingNESWiki/imgstore/apu/noise_envelope_control_tran.jpg)

![noise_envelope_counter_tran](/BreakingNESWiki/imgstore/apu/noise_envelope_counter_tran.jpg)

The circuit is identical to the Envelope of square channels. On the transistor circuit the labels of the intermediate signals may be different, but don't pay attention to this, the context should be clear.

![EnvelopeUnit](/BreakingNESWiki/imgstore/apu/EnvelopeUnit.jpg)

|EnvelopeUnit Signal|Noise Channel|
|---|---|
|WR_Reg|W400C|
|WR_LC|W400F|
|LC|RND/LC|

## Output

![noise_output_tran](/BreakingNESWiki/imgstore/apu/noise_output_tran.jpg)
