# H/V Control Logic

## H/V Decoder

The H/V decoder selects the necessary pixels and lines for the rest of H/V logic.

### H Decoder (NTSC PPU)

TBD.

### V Decoder (NTSC PPU)

TBD.

### H Decoder (PAL PPU)

![pal_h](/BreakingNESWiki/imgstore/pal_h.png)

```
0 01010 101 01000 01001 00000
1 10001 000 10000 10010 11111
1 11101 101 10000 00011 11111
0 00000 010 00000 00000 00000
1 10100 101 10000 00011 11010
0 01001 010 00000 10000 00101
1 11101 000 00000 10011 10101
0 00000 110 00000 00000 01010
0 11100 000 00000 10011 01100
1 00001 110 00000 00000 10011
1 11101 000 00000 00011 10111
0 00000 110 00000 00000 01000
0 11001 000 00100 00110 00110
1 00000 110 00011 00001 11001
1 11000 000 00101 00011 10101
0 00001 110 00010 00100 01010
0 10000 000 00000 00011 01011
1 01001 110 00000 00000 10100
0 00010 000 01000 00000 00000
0 01001 111 11100 11000 00000
```

|HPLA output|Meaning (pixel\* numbers of the line)|BLNK|VB|
|---|---|---|---|
|0|277| | |
|1|256| | |
|2|65| |yes|
|3|0-7, 256-263(?)| | |
|4|0-255|yes| |
|5|339| |yes|
|6|63| |yes|
|7|255| |yes|
|8|0-63| |yes|
|9|256-319| |yes|
|10|0-255|yes|yes|
|11|Each 0..1| |yes|
|12|Each 6..7| | |
|13|Each 4..5| | |
|14|320-335| |yes|
|15|0-255| |yes|
|16|Each 2..3| | |
|17|256| | |
|18|4| | |
|19|277| | |
|20|302| | |
|21|321| | |
|22|306| | |
|23|340| | |

\* - A "pixel" refers to a time interval that is based on PCLK. Not all "pixels" are displayed as an image, some are defined by different control portions of the signal, such as HSync, Color Burst, etc.

### V Decoder (PAL PPU)

![pal_v](/BreakingNESWiki/imgstore/pal_v.png)

```
001 00100 00
110 00001 11
111 00101 11
000 11010 00
111 00101 11
000 11010 00
111 00100 01
000 11011 10
011 00100 01
100 11011 10
101 11111 10
010 00000 01
101 11110 01
010 00001 10
111 11110 01
000 00001 10
100 10110 00
011 01001 11
```

|VPLA output|Meaning (line number)|
|---|---|
|0|272|
|1|269|
|2|1|
|3|240|
|4|241|
|5|0|
|6|240|
|7|311|
|8|311|
|9|265|

## H/V FSM

The H/V logic is a finite state machine (FSM) that controls all other PPU parts. Schematically it is just a set of latches, like "this latch is active from 64th to 128th pixel", so the corresponding control line coming from this latch is also active.

Preliminary results of the H/V logic circuits. We will need to check the "inversion" of the names later (slash before the line name).

"Horizontal" logic, responsible for generating control lines depending on the horizontal position of the beam (H):

<img src="/BreakingNESWiki/imgstore/7fc48a229053d2cf091195ec01a345ce.jpg" width="1000px">

### Cleaning H/V Counters

TBD.

### ODD/EVEN Logic

![odd_1](/BreakingNESWiki/imgstore/5c4d95b2bf506ef6b183cf8bb46e9433.jpg) ![odd_2](/BreakingNESWiki/imgstore/e4220e0351932b00026250fc2f3c858a.jpg) ![odd_3](/BreakingNESWiki/imgstore/e7d09137ee29ae53340df1cb2285585f.jpg)

The ODD/EVEN logic consists of two closed to each other pseudo latches controlled by two multiplexers. This results in a very clever "macro" latch.

TODO: The schematic should be analyzed again, because what the hell is this "macro-latch"... In addition, the scheme for PAL PPU is different from the NTSC version.
