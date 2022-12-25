# Length Counters

![apu_locator_length](/BreakingNESWiki/imgstore/apu/apu_locator_length.jpg)

![length_sm](/BreakingNESWiki/imgstore/apu/length_sm.jpg)

![LengthCounters](/BreakingNESWiki/imgstore/apu/LengthCounters.jpg)

The schematics of all four counters are identical, the only difference is in the signals (see below). For this reason, only the Square0 counter is shown in the drawings.

## Signals

|Signal|From where|Where to|Description|
|---|---|---|---|
|/LFO2|SoftCLK|Length Counters|Low frequency oscillation signal|
|SQA_LC|Square 0|Length Counters|Input carry for Square0 LC|
|SQB_LC|Square 1|Length Counters|Input carry for Square1 LC|
|TRI_LC|Triangle|Length Counters|Input carry for Triangle LC|
|RND_LC|Noise|Length Counters|Input carry for Noise LC|
|NOSQA|Length Counters|Square 0|Square0 LC does not count / disabled|
|NOSQB|Length Counters|Square 1|Square1 LC does not count / disabled|
|NOTRI|Length Counters|Triangle|Triangle LC does not count / disabled|
|NORND|Length Counters|Noise|Noise LC does not count / disabled|

|Counter|Input carry signal|End of count signal|Load counter signal|
|---|---|---|---|
|Square0|SQA_LC|NOSQA|W4003|
|Square1|SQB_LC|NOSQB|W4007|
|Triangle|TRI_LC|NOTRI|W400B|
|Noise|RND_LC|NORND|W400F|

## Length Decoder

![length_decoder_tran](/BreakingNESWiki/imgstore/apu/length_decoder_tran.jpg)

![Length_Decoder](/BreakingNESWiki/imgstore/apu/Length_Decoder.jpg)

|Decoder In|Decoder Out|
|---|---|
|0|0x9|
|1|0xfd|
|2|0x13|
|3|0x1|
|4|0x27|
|5|0x3|
|6|0x4f|
|7|0x5|
|8|0x9f|
|9|0x7|
|10|0x3b|
|11|0x9|
|12|0xd|
|13|0xb|
|14|0x19|
|15|0xd|
|16|0xb|
|17|0xf|
|18|0x17|
|19|0x11|
|20|0x2f|
|21|0x13|
|22|0x5f|
|23|0x15|
|24|0xbf|
|25|0x17|
|26|0x47|
|27|0x19|
|28|0xf|
|29|0x1b|
|30|0x1f|
|31|0x1d|

The first stage of the decoder (5-to-32 demultiplexer):

```
1010101010
1001101010
1010011010
1001011010
1010100110
1001100110
1010010110
1001010110

1010101001
1001101001
1010011001
1001011001
1010100101
1001100101
1010010101
1001010101

0110101010
0101101010
0110011010
0101011010
0110100110
0101100110
0110010110
0101010110

0110101001
0101101001
0110011001
0101011001
0110100101
0101100101
0110010101
0101010101
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

![Length_Decoder1](/BreakingNESWiki/imgstore/apu/Length_Decoder1.jpg)

The second stage of the decoder:

```
01000111
00100111
01100111
00010111
01010111
00110111
01110111
00001111

01001111
00101111
01101111
00011111
01011111
00111111
01111111
01000000

00000111
00001111
00011101
00000010
00000101
00001011
00010111
00101111

01100111
01001111
00100011
00000110
00001101
00011011
00110111
01101111
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

![Length_Decoder2](/BreakingNESWiki/imgstore/apu/Length_Decoder2.jpg)

## Length Counter Control

![length_counter_control_tran](/BreakingNESWiki/imgstore/apu/length_counter_control_tran.jpg)

![Length_Control](/BreakingNESWiki/imgstore/apu/Length_Control.jpg)

## Length Counter

The usual down counter.

![length_counter_tran](/BreakingNESWiki/imgstore/apu/length_counter_tran.jpg)

![Length_Counter](/BreakingNESWiki/imgstore/apu/Length_Counter.jpg)
