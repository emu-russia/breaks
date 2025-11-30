# Picture Address Register (PAR)

![ppu_locator_par](/BreakingNESWiki/imgstore/ppu/ppu_locator_par.jpg)

The circuit takes up the whole upper part and forms the tile (`Pattern`) address, which is set by `/PAD0-12` (13 bits).

![par_high](/BreakingNESWiki/imgstore/ppu/par_high.jpg)

![par_vinv](/BreakingNESWiki/imgstore/ppu/par_vinv.jpg)

![PAR](/BreakingNESWiki/imgstore/ppu/PAR.png)

Small circuits to control the loading of values into the output latches. The main emphasis is on selecting the mode of operation for sprites/backgrounds (signal `OBJ_READ`).

|![ParControl](/BreakingNESWiki/imgstore/ppu/ParControl.png)|![V_Inversion](/BreakingNESWiki/imgstore/ppu/V_Inversion.png)|
|---|---|

Bit circuits to form the output value `/PAD0-12` in slight variations:

![ParBit](/BreakingNESWiki/imgstore/ppu/ParBit.png)

![ParBit4](/BreakingNESWiki/imgstore/ppu/ParBit4.png)

![ParBitInv](/BreakingNESWiki/imgstore/ppu/ParBitInv.png)

Table of bits usage in addressing:

|Bit number|Source for BG|Source for OB (sprites 8x8)|Source for OB (sprites 8x16)|Role in addressing|
|---|---|---|---|---|
|0-2|Counter FV0-2|Sprite comparison OV0-2|Sprite comparison OV0-2|Pattern line number|
|3|/H1' Signal|/H1' Signal|/H1' Signal|A/B byte of the pattern line|
|4|Name Table, bit 0|OAM2, Tile Index Byte, bit 0|Sprite comparison OV3|Index in Pattern Table|
|5-11|Name Table, bits 1-7|OAM2, Tile Index Byte, bits 1-7|OAM2, Tile Index Byte, bits 1-7|Index in Pattern Table|
|12|BGSEL ($2000)|OBSEL ($2000)|OAM2, Tile Index Byte, bit 0|Selecting Pattern Table|