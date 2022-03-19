# H/V Decoder

![ppu_locator_hv_dec](/BreakingNESWiki/imgstore/ppu/ppu_locator_hv_dec.jpg)

The H/V decoder selects the necessary pixels and lines for the rest of H/V logic.

A "pixel" refers to a time interval that is based on PCLK. Not all "pixels" are displayed as an image, some are defined by different control portions of the signal, such as HSync, Color Burst, etc.

The principle of operation is as follows:
- The inputs are on the left, the outputs on the bottom. The inputs for the counter digits are in top-down order, starting from msb, for example: H8, /H8, H7, /H7 etc.
- The direct and inverse inputs are needed to check the value of the corresponding digit to `0` or `1`. For example, if the bit H8=1 and there is a transistor in the decoder, the output is "zeroed" (inactive).
- Each output takes the value `1` only for the required H or V values
- H Decoder has 2 additional inputs: VB and BLNK, which cut off the corresponding outputs when VB=1 or BLNK=1
- Technically, each decoder line is a multi-input NOR gate

Another topological feature of the H/V decoder is the lower left corner, the outputs from which go to the left, not down, into the Front Porch circuit.

## H Decoder (NTSC PPU)

![ntsc_h](/BreakingNESWiki/imgstore/ntsc_h.png)

|HPLA output|Pixel numbers of the line|Bitmask|VB Tran|BLNK Tran|Involved|
|---|---|---|---|---|---|
|0|279|01101010011001010100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS|
|6|63|10101001010101010101| |yes|EVAL|
|7|255|00010101010101010101| |yes|E/EV|
|8|0-63|10101000000000000001| |yes|I/OAM2|
|9|256-319|01101000000000000001| |yes|PAR/O|
|10|0-255|10000000000000000011|yes|yes|/VIS|
|11|Each 0..1|00000000000010100001| |yes|F/NT|
|12|Each 6..7|00000000000001010000| | |F/TB|
|13|Each 4..5|00000000000001100000| | |F/TA|
|14|320-335|01000110100000000001| |yes|/FO|
|15|0-255|10000000000000000001| |yes|F/AT|
|16|Each 2..3|00000000000010010000| | |F/AT|
|17|270|01101010100101011000| | |BPorch FF|
|18|328|01100110100110101000| | |BPorch FF|
|19|279|01101010011001010100| | |HBlank FF|
|20|304|01101001011010101000| | |HBlank FF|
|21|323|01100110101010010100| | |BURST/VSYNC FF|
|22|308|01101001011001101000| | |BURST/VSYNC FF|
|23|340|01100110011001101000| | |HCounter clear / VCounter step|

## V Decoder (NTSC PPU)

![ntsc_v](/BreakingNESWiki/imgstore/ntsc_v.png)

|VPLA output|Line number|Bitmask|Involved|
|---|---|---|---|
|0|247|000101010110010101| |
|1|244|000101010110011010| |
|2|261|011010101010011001| |
|3|241|000101010110101001| |
|4|241|000101010110101001| |
|5|0|101010101010101010| |
|6|240|000101010110101010| |
|7|261|011010101010011001| |
|8|261|011010101010011001| |

## H Decoder (PAL PPU)

![pal_h](/BreakingNESWiki/imgstore/pal_h.png)

|HPLA output|Pixel numbers of the line|Bitmask|VB Tran|BLNK Tran|Involved|
|---|---|---|---|---|---|
|0|277|01101010011001100100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS|
|6|63|10101001010101010101| |yes|EVAL|
|7|255|00010101010101010101| |yes|E/EV|
|8|0-63|10101000000000000001| |yes|I/OAM2|
|9|256-319|01101000000000000001| |yes|PAR/O|
|10|0-255|10000000000000000011|yes|yes|/VIS|
|11|Each 0..1|00000000000010100001| |yes|F/NT|
|12|Each 6..7|00000000000001010000| | |F/TB|
|13|Each 4..5|00000000000001100000| | |F/TA|
|14|320-335|01000110100000000001| |yes|/FO|
|15|0-255|10000000000000000001| |yes|F/AT|
|16|Each 2..3|00000000000010010000| | |F/AT|
|17|256|01101010101010101000| | |BPorch FF|
|18|4|10101010101001101000| | |BPorch FF|
|19|277|01101010011001100100| | |HBlank FF|
|20|302|01101001100101011000| | |HBlank FF|
|21|321|01100110101010100100| | |BURST/VSYNC FF|
|22|306|01101001011010011000| | |BURST/VSYNC FF|
|23|340|01100110011001101000| | |HCounter clear / VCounter step|

## V Decoder (PAL PPU)

![pal_v](/BreakingNESWiki/imgstore/pal_v.png)

|VPLA output|Line number|Bitmask|Involved|
|---|---|---|---|
|0|272|011010100110101010| |
|1|269|011010101001011001| |
|2|1|101010101010101001| |
|3|240|000101010110101010| |
|4|241|000101010110101001| |
|5|0|101010101010101010| |
|6|240|000101010110101010| |
|7|311|011010010110010101| |
|8|311|011010010110010101| |
|9|265|011010101001101001| |
