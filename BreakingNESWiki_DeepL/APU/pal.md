# RP 2A07

![RP2A07A_package](/BreakingNESWiki/imgstore/apu/pal/RP2A07A_package.jpg)

Comparing the topology of 2A03 and 2A07 you can see that 2A03 has some elements from 2A07 that are not used:
- Regular RDY terminal connection, instead of the 2A07 test mode
- Traces of the topology of the PAL version of the divider in 2A03

## Divider

![div](/BreakingNESWiki/imgstore/apu/pal/div.jpg)

## SoftCLK PLA

![softclk_decoder_2a07](/BreakingNESWiki/imgstore/apu/pal/softclk_decoder_2a07.jpg)

```
000010
111101
101000
010111
000010
111101
011110
100001
110010
001101
000110
111001
100110
011001
100100
011011
100100
011011
110110
001001
101000
010111
101100
010011
000000
111111
011000
100111
010000
101111
```

The placement is topological. 1 means there is a transistor, 0 means there is no transistor.

The SoftCLK control circuits themselves do not differ. Analysis fragment:

![softclk](/BreakingNESWiki/imgstore/apu/pal/softclk.jpg)

## DPCM Decoder

![dpcm_decoder_2a07](/BreakingNESWiki/imgstore/apu/pal/dpcm_decoder_2a07.jpg)

The first stage of the decoder (4-to-16 demultiplexer):

```
10101010
01101010
10011010
01011010
10100110
01100110
10010110
01010110

10101001
01101001
10011001
01011001
10100101
01100101
10010101
01010101
```

The second stage of the decoder:

```
010101000
011100100
011100011
111010101
000110010
000110000
001011100
110110101

011001101
110100011
110000100
000011110
010111100
100100110
110011000
000101000
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

## Noise Channel Decoder

![noise_decoder_2a07](/BreakingNESWiki/imgstore/apu/pal/noise_decoder_2a07.jpg)

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
10010100 00000111
01100011 00001111
11001001 01010111
10001011 00011111
00100111 00100011
10001010 11111111
10101100 11010011
01100001 11100101
01011101 11000011
00111010 10001100
10101010 00010011
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

## Test Mode

There is no debug mode in 2A07 as such: all circuits for reading debug registers were cut out and the register operation decoder was shortened.

Nevertheless, there are some traces left.

## Register Select

TBD.

## RDY

TBD.

## Debug write to register $401A (triangle channel)

What used to be the W401A signal is now grounded:

![w401a](/BreakingNESWiki/imgstore/apu/pal/w401a.jpg)

