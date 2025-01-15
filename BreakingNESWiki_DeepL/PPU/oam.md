# OAM

![ppu_locator_oam](/BreakingNESWiki/imgstore/ppu/ppu_locator_oam.jpg)

Sprite memory (OAM, Object Attribute Memory) takes up almost a quarter of the PPU's area, which was a luxury in those days. The size of the OAM is 2112 bits, of which 1856 are used to store 64 sprites (29 bits per sprite) and the remaining 256 bits are used in a special way to sample the 8 current sprites to be shown on the current line. This area of the OAM is usually called "temporary OAM" or OAM2.

Сombined image of the memory cell topology:

![ppu_oam_closeup](/BreakingNESWiki/imgstore/ppu/ppu_oam_closeup.jpg)

OAM components:
- Memory Cell Array (2112 cells)
- Column Decoder
- Row Decoder
- OAM Buffer control circuit
- OAM Buffer (OB)

![OAM_All](/BreakingNESWiki/imgstore/ppu/OAM_All.png)

Signals table:

|Signal/group|Description|
|---|---|
|**OAM Address**||
|/OAM0-7|Address of the main OAM (in inverse logic)|
|OAM8|1: Use Temp OAM|
|**FSM**||
|BLNK|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|I/OAM2|"Init OAM2". Initialize an additional (temp) OAM|
|/VIS|"Not Visible". The invisible part of the signal (used in sprite logic)|
|**From the sprite comparison**||
|SPR_OV|Sprite Overflow|
|OAMCTR2|OAM Buffer Control|
|**CPU I/F**||
|/R4|0: Read $2004|
|/W4|0: Write $2004|
|/DBE|0: "Data Bus Enable", enable CPU interface|
|**Internal signals**||
|COL0-7|Defines the column to access the main OAM|
|COLZ|Defines the column to access the Temp OAM|
|ROW0-31|Determines the row number. During PCLK all ROW outputs are 0.|
|OB/OAM|1: Write the current value of OB to the output latch|
|/WE|0: write to the selected OAM cell the value from the output latch|
|**Output signals**||
|OFETCH|"OAM Fetch"|
|OB0-7|Current OAM Buffer value (from OB_FF)|

## OAM Layout

By convention, groups of cells that are addressed by the lowest bits of the address will be considered "columns" (bit lines), and groups of cells that are addressed by the highest bits will be considered "rows" (word lines).

- /OAM0-2: Define a column (with a small feature, see below)
- /OAM3-7: Define the row

Additionally, you can see the OAM cell allocation map here: https://github.com/ogamespec/OAMMap

## Memory Cell

|![oam_cell_topo](/BreakingNESWiki/imgstore/ppu/oam_cell_topo.png)|![oam_cell_tran2](/BreakingNESWiki/imgstore/ppu/oam_cell_tran2.png)|![oam_cell](/BreakingNESWiki/imgstore/ppu/oam_cell.jpg)|
|---|---|---|

It is a typical 4T-DRAM cell, the gates of the looped transistors act as capacitors, so the value on the cell is constantly degrading.

The OAM memory degradation effect is called "OAM Decay" and it is widely known. To combat this effect, programs for the NES contain an OAM cache in regular CPU memory (usually at $200 address) and every VBlank copies this cache to OAM using the APU's sprite DMA.

During PCLK bit line "precharge" is made.

TBD: Calculate or measure cell degradation timings.

![OAM](/BreakingNESWiki/imgstore/ppu/OAM.png)

![OAM_Lane](/BreakingNESWiki/imgstore/ppu/OAM_Lane.png)

## Column Decoder

![oam_col_decoder](/BreakingNESWiki/imgstore/ppu/oam_col_decoder.jpg)

The circuit is a 1-of-n decoder.

|COL outputs for OAM Buffer bits 0, 1, 5-7|COL outputs for OAM Buffer bits 2-4|
|---|---|
|![oam_col_outputs1](/BreakingNESWiki/imgstore/ppu/oam_col_outputs1.jpg)|![oam_col_outputs2](/BreakingNESWiki/imgstore/ppu/oam_col_outputs2.jpg)|

The skipping of bit lines (columns) at bits 2-4 is done to save memory. If we match the OAM address with the COL values, which are obtained from the lowest bits, we get the following:

```
OamAddr: 0, col: 0
OamAddr: 1, col: 1
OamAddr: 2, col: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 3, col: 3
OamAddr: 4, col: 4
OamAddr: 5, col: 5
OamAddr: 6, col: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 7, col: 7
OamAddr: 8, col: 0
OamAddr: 9, col: 1
OamAddr: 10, col: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 11, col: 3
OamAddr: 12, col: 4
OamAddr: 13, col: 5
OamAddr: 14, col: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 15, col: 7
...
```

As you can see COL2 and COL6 fall just on the attribute byte of the sprite, which does not use bits 2-4.

For Temp OAM skipping of bits is not performed in order not to complicate the already complicated circuitry.

## Row Decoder

![oam_row_decoder](/BreakingNESWiki/imgstore/ppu/oam_row_decoder.jpg)

The circuit is a 1-of-n decoder.

The decoder is designed so that the rows are numbered from right to left (0-31). But due to the fact that in NTSC PPU the OAM address is given in inverted form (/OAM0-7) - logical numbering of rows is mixed up. The result is as follows:

|Row number (topological)|NTSC PPU row number (logical)|
|---|---|
|31|111 11|
|30|011 11|
|29|101 11|
|28|001 11|
|27|110 11|
|26|010 11|
|25|100 11|
|24|000 11|
|23-16|XXX 01|
|15-8|XXX 10|
|7-0|XXX 00|

Or if in order from right to left, grouped into 4 groups:
```
0 16 8 24 4 20 12 28
1 17 9 25 5 21 13 29
2 18 10 26 6 22 14 30
3 19 11 27 7 23 15 31
```

In PAL PPU the numbering corresponds to the sequence 0-31 as designed by the decoder, from right to left, due to the fact that the OAM address is fed in forward logic (`OAM0-7`).

During PCLK = 1 all ROW outputs are 0, i.e. access to all OAM cells is closed.

## Address Decoder

General schematic of the column/row decoder:

![OAM_AddressDecoder](/BreakingNESWiki/imgstore/ppu/OAM_AddressDecoder.png)

## OAM Buffer Control

The circuit is used to set the operating modes of the OB and to control the transfer of values between it and the OAM.

![oam_buffer_control](/BreakingNESWiki/imgstore/ppu/oam_buffer_control.jpg)

![OAM_Control](/BreakingNESWiki/imgstore/ppu/OAM_Control.png)

## OAM Buffer (OB)

The OAM Buffer is used as a transfer point to store a byte that needs to be written to the OAM or a byte that has been read from the OAM for consumers.

The circuit consists of 8 identical circuits for each bit:

![oam_buffer_bit](/BreakingNESWiki/imgstore/ppu/oam_buffer_bit.jpg)

(The picture shows the circuit for storing the OB0 bit).

![OAM_Buffer](/BreakingNESWiki/imgstore/ppu/OAM_Buffer.png)

![OAM_BufferBit](/BreakingNESWiki/imgstore/ppu/OAM_BufferBit.png)

The OB bit circuit is very difficult to understand even for experienced circuit designers, because it is very confusing, besides it deals with Tri-State logic (in Verilog terms - `inout`), which is related to the access to OAM Cells.

Here are the distinctive features of the OB:
- The circuit contains 2 FFs and 2 latches
- `Input_FF` is used to load a value from the OAM Cell and is needed to "secure" the rest of the circuit from `z` values that may be on the cell. During PCLK = 1 this FF is cleared (simultaneously with OAM Precharge)
- `OB_FF` stores the last current value of the OAM Buffer. From these FFs, the OB0-7 signal values are output to the outside. FF is opened during PCLK = 0.
- The `R4 latch` is used for CPU I/F. It stores the value to read register $2004. The latch opens during PCLK = 1.
- The output latch (`out_latch`) is used to write a new value to the OAM Cell. The new value can come from OB_FF (`OB/OAM` = 1) or from the data bus (`BLNK` = 1). The `OB/OAM` and `BLNK` signals never take the value `1` at the same time, but can take the value `0` at the same time (that is, when the output latch is closed).
- The value from the output latch is stored in the selected OAM Cell only when allowed by the `/WE` = 0 signal.
