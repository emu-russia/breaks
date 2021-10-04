# H/V Decoder

The H/V decoder selects the necessary pixels and lines for the rest of H/V logic.

## H Decoder (NTSC PPU)

![ntsc_h](/BreakingNESWiki/imgstore/ntsc_h.png)

```
0 01010 101 01000 01000 00000
1 10001 000 10000 10011 11111
1 11101 101 10000 00011 11111
0 00000 010 00000 00000 00000
1 10100 101 10000 00010 11010
0 01001 010 00000 10001 00101
1 11101 000 00000 10011 10101
0 00000 110 00000 00000 01010
0 11100 000 00000 10011 00100
1 00001 110 00000 00000 11011
1 11101 000 00000 00000 11111
0 00000 110 00000 00011 00000
0 11001 000 00100 00101 01100
1 00000 110 00011 00010 10011
0 11000 000 00101 00001 01011
1 00001 110 00010 00110 10100
0 10000 000 00000 00011 01011
1 01001 110 00000 00000 10100

0 00010 000 01000 00000 00000
0 01001 111 11100 11000 00000
```

|HPLA output|Pixel\* numbers of the line|VB|BLNK|Meaning|
|---|---|---|---|---|
|0|279| | |FPorch FF|
|1|256| | |FPorch FF|
|2|65| |yes|S/EV|
|3|0-7| | |CLIP_O / CLIP_B|
|4|0-255|yes| |CLIP_O / CLIP_B|
|5|339| |yes|0/HPOS|
|6|63| |yes|EVAL|
|7|255| |yes|E/EV|
|8|0-63| |yes|I/OAM2|
|9|256-319| |yes|PAR/O|
|10|0-255|yes|yes|/VIS|
|11|0..1| |yes|F/NT|
|12|6..7| | |F/TB|
|13|4..5| | |F/TA|
|14|320-335| |yes|/FO|
|15|0-255| |yes|F/AT|
|16|2..3| | |F/AT|
|17|270| | |BPorch FF|
|18|328| | |BPorch FF|
|19|279| | |HBlank FF|
|20|304| | |HBlank FF|
|21|323| | |BURST/VSYNC FF|
|22|308| | |BURST/VSYNC FF|
|23|340| | |HCounter clear / VCounter step|

\* - A "pixel" refers to a time interval that is based on PCLK. Not all "pixels" are displayed as an image, some are defined by different control portions of the signal, such as HSync, Color Burst, etc.

## V Decoder (NTSC PPU)

![ntsc_v](/BreakingNESWiki/imgstore/ntsc_v.png)

```
000 00100 0
001 00001 1
001 00101 1
110 11010 0
001 00101 1
110 11010 0
001 00101 1
110 11010 0
001 00101 1
110 11010 0
111 11111 1
000 00000 0
000 11110 0
111 00001 1
011 11111 1
100 00000 0
010 00110 0
101 11001 1
```

|VPLA output|Line number|Meaning|
|---|---|---|
|0|247| |
|1|244| |
|2|261| |
|3|241| |
|4|241| |
|5|0| |
|6|240| |
|7|261| |
|8|261| |

## H Decoder (PAL PPU)

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

|HPLA output|Pixel\* numbers of the line|VB|BLNK|Meaning|
|---|---|---|---|---|
|0|277| | |FPorch FF|
|1|256| | |FPorch FF|
|2|65| |yes|S/EV|
|3|0-7, 256-263(?)| | |CLIP_O / CLIP_B|
|4|0-255|yes| |CLIP_O / CLIP_B|
|5|339| |yes|0/HPOS|
|6|63| |yes|EVAL|
|7|255| |yes|E/EV|
|8|0-63| |yes|I/OAM2|
|9|256-319| |yes|PAR/O|
|10|0-255|yes|yes|/VIS|
|11|Each 0..1| |yes|F/NT|
|12|Each 6..7| | |F/TB|
|13|Each 4..5| | |F/TA|
|14|320-335| |yes|/FO|
|15|0-255| |yes|F/AT|
|16|Each 2..3| | |F/AT|
|17|256| | |BPorch FF|
|18|4| | |BPorch FF|
|19|277| | |HBlank FF|
|20|302| | |HBlank FF|
|21|321| | |BURST/VSYNC FF|
|22|306| | |BURST/VSYNC FF|
|23|340| | |HCounter clear / VCounter step|

\* - A "pixel" refers to a time interval that is based on PCLK. Not all "pixels" are displayed as an image, some are defined by different control portions of the signal, such as HSync, Color Burst, etc.

## V Decoder (PAL PPU)

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

|VPLA output|Line number|Meaning|
|---|---|---|
|0|272| |
|1|269| |
|2|1| |
|3|240| |
|4|241| |
|5|0| |
|6|240| |
|7|311| |
|8|311| |
|9|265| |
