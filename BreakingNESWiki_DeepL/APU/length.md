# Length Counters

![apu_locator_length](/BreakingNESWiki/imgstore/apu/apu_locator_length.jpg)

![length_sm](/BreakingNESWiki/imgstore/apu/length_sm.jpg)

## Length Decoder

![length_decoder_tran](/BreakingNESWiki/imgstore/apu/length_decoder_tran.jpg)

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

## Length Counter Control

![length_counter_control_tran](/BreakingNESWiki/imgstore/apu/length_counter_control_tran.jpg)

## Length Counter

![length_counter_tran](/BreakingNESWiki/imgstore/apu/length_counter_tran.jpg)
